import Foundation

public actor WebSocketEngine: WebSocketClient {
    
    private let urlSession: URLSessionTaskProtocol
    private let sessionDelegate: SessionDelegate
    private var webSocketTask: WebSocketTaskProtocol?
    
    private var fallbackWebSocketTaskInterceptor = DefaultWebSocketTaskInterceptor()
    
    // MARK: Receive message
    private var messageContinuation: AsyncThrowingStream<InboundMessage, Error>.Continuation?
    private var messageStreamCreated = false

    // MARK: Connection State
    private var connectionState: WebSocketConnectionState = .idle {
        didSet {
            connectionStateContinuation.yield(connectionState)
            
            // Finish continuation on terminal states
            switch connectionState {
            case .disconnected, .failed, .connectionLost:
                connectionStateContinuation.finish()
            case .idle, .connecting, .connected:
                break
            }
        }
    }
    private nonisolated(unsafe) let _connectionStateStream: AsyncStream<WebSocketConnectionState>
    private let connectionStateContinuation: AsyncStream<WebSocketConnectionState>.Continuation
    public nonisolated var connectionStateStream: AsyncStream<WebSocketConnectionState> {
        _connectionStateStream
    }
    
    // MARK: Connection Continuation
    /// Used to suspend `connect()` until the delegate reports connection success/failure
    private var connectionContinuation: CheckedContinuation<String?, Error>?

    // MARK: - init
    
    public init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        sessionDelegate: SessionDelegate? = nil
    ) {
        let (stream, continuation) = AsyncStream<WebSocketConnectionState>.makeStream()
        self._connectionStateStream = stream
        self.connectionStateContinuation = continuation
        
        if let urlSession = urlSession as? URLSession {
            if let existingDelegate = urlSession.delegate as? SessionDelegate {
                self.sessionDelegate = existingDelegate
                self.urlSession = urlSession
            } else {
                let newDelegate = sessionDelegate ?? SessionDelegate()
                let newSession = URLSession(
                    configuration: urlSession.configuration,
                    delegate: newDelegate,
                    delegateQueue: urlSession.delegateQueue
                )
                self.sessionDelegate = newDelegate
                self.urlSession = newSession
            }
        } else {
            self.sessionDelegate = sessionDelegate ?? SessionDelegate()
            self.urlSession = urlSession
        }
    }
    
    // MARK: deinit
    
    deinit {
        // Cancel any pending connection
        connectionContinuation?.resume(throwing: WebSocketError.forcedDisconnection)
        connectionContinuation = nil
        
        // Finish all continuations
        connectionStateContinuation.finish()
        messageContinuation?.finish()
        
        // Cancel task
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
    
    // MARK: - Connect
    
    public func connect(with url: URL,
                        protocols: [String],
                        pingPongIntervalSeconds: UInt64 = 30,
                        pingPongMaximumConsecutiveFailures: Int = 3) async throws {
        if case .connecting = connectionState {
            throw WebSocketError.stillConnecting
        }
        if case .connected(protocol: _) = connectionState {
            throw WebSocketError.alreadyConnected
        }
        
        webSocketTask = urlSession.webSocketTaskInspectable(with: url, protocols: protocols)
        webSocketTask?.resume()
        
        connectionState = .connecting
        
        let connectedProtocol = try await waitForConnection()
        
        connectionState = .connected(protocol: connectedProtocol)
        
        startPingLoop(intervalSeconds: pingPongIntervalSeconds,
                      maximumConsecutiveFailures: pingPongMaximumConsecutiveFailures)
    }
    
    // MARK: wait for connection
    
    private func waitForConnection() async throws -> String? {
        setupWebSocketEventHandler()
        
        // Suspend until the delegate calls resumeConnection
        return try await withCheckedThrowingContinuation { continuation in
            self.connectionContinuation = continuation
        }
    }
    
    // MARK: - Disconnect
    
    /// Handle client manually disconnecting from web socket
    public func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async {
        // Cancel any pending connection
        connectionContinuation?.resume(throwing: WebSocketError.forcedDisconnection)
        connectionContinuation = nil
        
        // Finish all continuations
        messageContinuation?.finish()
        messageContinuation = nil
        messageStreamCreated = false
        
        // Cancel webSocketTask
        webSocketTask?.cancel(with: closeCode, reason: reason)
        webSocketTask = nil
        
        // update state
        connectionState = .disconnected
    }
    
    /// Handle unexpected connection loss while connected
    private func handleConnectionLoss(error: WebSocketError) async {
        // Cancel any pending connection
        connectionContinuation?.resume(throwing: WebSocketError.forcedDisconnection)
        connectionContinuation = nil
        
        // Finish all continuations
        messageContinuation?.finish()
        messageContinuation = nil
        messageStreamCreated = false
        
        // Cancel webSocketTask
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        // update state
        connectionState = .connectionLost(reason: error)
    }
    
    // MARK: - Send message
    
    public func send(_ message: OutboundMessage) async throws {
        guard case .connected = connectionState else {
            throw WebSocketError.notConnected
        }
        
        guard let task = webSocketTask else {
            throw WebSocketError.taskNotInitialized
        }
        
        do {
            try await task.send(message)
        } catch {
            throw WebSocketError.sendFailed(underlying: error)
        }
    }

    // MARK: - Receive message

    nonisolated public func receiveMessages() -> AsyncThrowingStream<InboundMessage, Error> {
        return AsyncThrowingStream<InboundMessage, Error> { continuation in
            let task = Task { [weak self] in
                guard let self else {
                    continuation.finish()
                    return
                }
                await self.setMessageContinuation(continuation)
                await self.startReceivingMessages(continuation)
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    // Helper to set continuation on actor
    private func setMessageContinuation(_ continuation: AsyncThrowingStream<InboundMessage, Error>.Continuation) async {
        guard case .connected = connectionState else {
            continuation.finish(throwing: WebSocketError.notConnected)
            return
        }
        guard !messageStreamCreated else {
            continuation.finish(throwing: WebSocketError.streamAlreadyCreated)
            return
        }
        
        self.messageContinuation = continuation
        messageStreamCreated = true
        
    }
    
    private func startReceivingMessages(_ continuation: AsyncThrowingStream<InboundMessage, Error>.Continuation) async {
        guard let task = webSocketTask else {
            continuation.finish(throwing: WebSocketError.notConnected)
            return
        }
        
        while await isConnectedState() {
            do {
                let message = try await task.receive()
                continuation.yield(message)
            } catch {
                let wsError = WebSocketError.receiveFailed(underlying: error)
                                
                // Notify the engine that the connection is no longer valid
                await handleConnectionLoss(error: wsError)
                
                // IMPORTANT: finish WITH an error
                continuation.finish(throwing: wsError)
                return
            }
        }
        
        // If loop exits, connection state changed
        continuation.finish()
    }

}

// MARK: - HELPERS

extension WebSocketEngine {

    // MARK: - observe delegate
    
    private func setupWebSocketEventHandler() {
        if sessionDelegate.webSocketTaskInterceptor == nil {
            sessionDelegate.webSocketTaskInterceptor = fallbackWebSocketTaskInterceptor
        }
        
        // Only set once (idempotent)
        guard sessionDelegate.webSocketTaskInterceptor?.onEvent == nil else { return }
        
        sessionDelegate.webSocketTaskInterceptor?.onEvent = { [weak self] event in
            Task { await self?.handleWebSocketEvent(event) }
        }
    }
    
    /// Central event handler for ALL WebSocket events
    private func handleWebSocketEvent(_ event: WebSocketTaskEvent) async {
        switch (connectionState, event) {
        // Ignore events when not actively connecting/connected
        case (.idle, _), (.disconnected, _), (.connectionLost, _), (.failed, _):
            break
            
        // Initial connection phase
        case (.connecting, .didOpenWithProtocol(let proto)):
            resumeConnection(with: proto)
            
        case (.connecting, .didOpenWithError(let err)):
            resumeConnection(throwing: .connectionFailed(underlying: err))
            
        case (.connecting, .didClose(let code, let reason)):
            resumeConnection(throwing: .unexpectedDisconnection(code: code, reason: parseReason(reason)))
            
        // Active connection phase
        case (.connected, .didClose(let code, let reason)):
            let error = WebSocketError.unexpectedDisconnection(code: code, reason: parseReason(reason))
            print("Delegate detected closure: code=\(code.rawValue), reason=\(parseReason(reason) ?? "none")")
            await handleConnectionLoss(error: error)
            
        case (.connected, _):
            break // Ignore redundant open events when already connected
        }
    }
    
    /// Resume the connection continuation with a successful protocol
    private func resumeConnection(with protocolStr: String?) {
        connectionContinuation?.resume(returning: protocolStr)
        connectionContinuation = nil
    }
    
    /// Resume the connection continuation with an error
    private func resumeConnection(throwing error: WebSocketError) {
        connectionContinuation?.resume(throwing: error)
        connectionContinuation = nil
        connectionState = .failed(error: error)
    }
    
    private func parseReason(_ reason: Data?) -> String? {
        reason.flatMap { String(data: $0, encoding: .utf8) }
    }
    
    // MARK: - ping pong
    
    private func startPingLoop(intervalSeconds: UInt64 = 30,
                               maximumConsecutiveFailures: Int = 3) {
        Task { [weak self] in
            guard let self else { return }
            
            var consecutiveFailures = 0
            let maxFailures = maximumConsecutiveFailures
            
            while await self.isConnectedState() {
                do {
                    try await self.sendPing()
                    consecutiveFailures = 0
                } catch {
                    consecutiveFailures += 1
                    print("Ping failed (\(consecutiveFailures)/\(maxFailures)): \(error)")
                }
                
                if consecutiveFailures >= maxFailures {
                    let error = WebSocketError.keepAliveFailure(consecutiveFailures: consecutiveFailures)
                    print("Ping loop detected connection loss")
                    await self.handleConnectionLoss(error: error)
                    break
                }
                
                try? await Task.sleep(nanoseconds: intervalSeconds * 1_000_000_000)
            }
        }
    }
    
    private func sendPing() async throws {
        guard let task = webSocketTask else {
            throw WebSocketError.taskNotInitialized
        }
        
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                task.sendPing { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        } catch {
            throw WebSocketError.pingFailed(underlying: error)
        }
    }
    
}

extension WebSocketEngine {
    private func isConnectedState() async -> Bool {
        if case .connected = connectionState { return true }
        return false
    }
}
