import Foundation

public actor WebSocketEngine: WebSocketClient {
    
    // MARK: - Dependencies
    
    private let urlSession: URLSessionTaskProtocol
    private var sessionDelegate: SessionDelegate
    private let webSocketRequest: URLRequest
    private let pingConfig: PingConfig
    
    private var pingTask: Task<Void, Never>?
    
    // MARK: - WS interceptor
    
    private let fallbackWebSocketTaskInterceptor: WebSocketTaskInterceptor = DefaultWebSocketTaskInterceptor()
    
    // MARK: - WebSocketTask
    
    private var webSocketTask: WebSocketTaskProtocol?
    
    // MARK: - Connection State
    
    private var connectionState: WebSocketConnectionState = .idle {
        didSet {
            connectionStateContinuation.yield(connectionState)
        }
    }
    private nonisolated(unsafe) let _stateChanges: AsyncStream<WebSocketConnectionState>
    private let connectionStateContinuation: AsyncStream<WebSocketConnectionState>.Continuation
    
    /// Used to suspend `connect()` until the delegate reports connection success/failure
    private var connectionContinuation: CheckedContinuation<String?, Error>?
    
    // MARK: - Message Receiving
    
    private nonisolated(unsafe) let _messages: AsyncThrowingStream<InboundMessage, Error>
    private nonisolated(unsafe) let messageContinuation: AsyncThrowingStream<InboundMessage, Error>.Continuation
    private var messageReceivingTask: Task<Void, Never>?
    
    // MARK: - init
    
    public init(
        urlRequest: URLRequest,
        pingConfig: PingConfig = PingConfig(),
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        sessionDelegate: SessionDelegate? = nil
    ) {
        self.webSocketRequest = urlRequest
        self.pingConfig = pingConfig
        if let urlSession = urlSession as? URLSession {
            // If the session already has a delegate, use it (if it's a SessionDelegate)
            if let existingDelegate = urlSession.delegate as? SessionDelegate {
                self.sessionDelegate = existingDelegate
                self.urlSession = urlSession
            } else {
                // If no delegate or not a SessionDelegate, create one
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
            // For mocks or custom protocol types
            self.sessionDelegate = sessionDelegate ?? SessionDelegate()
            self.urlSession = urlSession
        }
        
        let (stream, continuation) = AsyncStream<WebSocketConnectionState>.makeStream()
        self._stateChanges = stream
        self.connectionStateContinuation = continuation
        
        // Create the long-lived message stream
        let (messageStream, messageContinuation) = AsyncThrowingStream<InboundMessage, Error>.makeStream()
        self._messages = messageStream
        self.messageContinuation = messageContinuation
    }
    
    // MARK: - deinit
    
    deinit {
        // Cancel any pending connection
        connectionContinuation?.resume(throwing: WebSocketError.forcedDisconnection)
        connectionContinuation = nil
        
        // Finish all continuations to release any waiting iterators
        connectionStateContinuation.finish()
        messageContinuation.finish()
        
        // Cancel all background tasks
        pingTask?.cancel()
        messageReceivingTask?.cancel()
        
        // Cancel webSocket task
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        
        // Clear the event handler to prevent new tasks from being created after deallocation
        sessionDelegate.webSocketTaskInterceptor?.onEvent = nil
    }
    
    // MARK: - state change observation
    
    public nonisolated var stateChanges: AsyncStream<WebSocketConnectionState> {
        _stateChanges
    }
    
    // MARK: - connect
    
    public func connect() async throws {
        // Validate current state
        if case .connecting = connectionState {
            throw WebSocketError.stillConnecting
        }
        if case .connected(protocol: _) = connectionState {
            throw WebSocketError.alreadyConnected
        }
        
        // Create and resume WebSocket task
        webSocketTask = urlSession.webSocketTaskInspectable(with: webSocketRequest)
        webSocketTask?.resume()
        
        setupWebSocketEventHandler()
        
        try await waitForConnection()
        
        startPingLoop(intervalSeconds: pingConfig.pingInterval,
                      maximumConsecutiveFailures: pingConfig.maxPingFailures)
        
        // Start receiving messages when connected
        await startReceivingMessages()
    }
    
    // MARK: - disconnect
    
    public func disconnect(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async {
        cleanup(closeCode: closeCode, reason: reason, newState: .disconnected, error: .forcedDisconnection)
    }
    
    private func handleConnectionLoss(error: WebSocketError) async {
        cleanup(closeCode: .goingAway, reason: nil, newState: .connectionLost(reason: error), error: error)
    }
    
    private func cleanup(closeCode: URLSessionWebSocketTask.CloseCode,
                         reason: Data?,
                         newState: WebSocketConnectionState,
                         error: WebSocketError) {
        connectionContinuation?.resume(throwing: error)
        connectionContinuation = nil
        
        // Stop receiving messages (but don't finish the stream - it's long-lived)
        messageReceivingTask?.cancel()
        messageReceivingTask = nil
        
        webSocketTask?.cancel(with: closeCode, reason: reason)
        webSocketTask = nil
        
        connectionState = newState
        
        pingTask?.cancel()
        pingTask = nil
        
        // Clear the event handler to prevent new tasks from being created
        sessionDelegate.webSocketTaskInterceptor?.onEvent = nil
    }
    
    // MARK: - send
    
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
    
    // MARK: - messages
    
    /// Returns a long-lived stream of messages that persists across disconnections and reconnections.
    /// The stream only finishes when the engine is deallocated or encounters a permanent error.
    nonisolated public func messages() -> AsyncThrowingStream<InboundMessage, Error> {
        return _messages
    }
    
}

private extension WebSocketEngine {
    
    // MARK: - handle open/close events

    private func setupWebSocketEventHandler() {
        if sessionDelegate.webSocketTaskInterceptor == nil {
            sessionDelegate.webSocketTaskInterceptor = fallbackWebSocketTaskInterceptor
        }
        
        guard sessionDelegate.webSocketTaskInterceptor?.onEvent == nil else { return }
        
        sessionDelegate.webSocketTaskInterceptor?.onEvent = { [weak self] event in
            Task {
                await self?.handleWebSocketEvent(event)
            }
        }
    }
    
    private func handleWebSocketEvent(_ event: WebSocketTaskEvent) async {
        switch (connectionState, event) {
        case (.idle, _), (.disconnected, _), (.connectionLost, _), (.failed, _):
            break
            
        case (.connecting, .didOpenWithProtocol(let proto)):
            resumeConnection(with: proto)
            
        case (.connecting, .didOpenWithError(let err)):
            resumeConnection(throwing: .connectionFailed(underlying: err))
            
        case (.connecting, .didClose(let code, let reason)):
            resumeConnection(throwing: .unexpectedDisconnection(code: code, reason: parseReason(reason)))
            
        case (.connected, .didClose(let code, let reason)):
            let error = WebSocketError.unexpectedDisconnection(code: code, reason: parseReason(reason))
            print("Delegate detected closure: code=\(code.rawValue), reason=\(parseReason(reason) ?? "none")")
            await handleConnectionLoss(error: error)
            
        case (.connected, _):
            break
        }
    }
    
    private func resumeConnection(with protocolStr: String?) {
        connectionContinuation?.resume(returning: protocolStr)
        connectionContinuation = nil
    }
    
    private func resumeConnection(throwing error: WebSocketError) {
        connectionContinuation?.resume(throwing: error)
        connectionContinuation = nil
        connectionState = .failed(error: error)
    }
    
    private func parseReason(_ reason: Data?) -> String? {
        reason.flatMap { String(data: $0, encoding: .utf8) }
    }
    
    // MARK: - wait for connection to be established
    
    private func waitForConnection() async throws {
        connectionState = .connecting

        do {
            let connectedProtocol = try await withCheckedThrowingContinuation { continuation in
                self.connectionContinuation = continuation
            }
            connectionState = .connected(protocol: connectedProtocol)
        } catch let wsError as WebSocketError {
            connectionState = .failed(error: wsError)
            throw wsError
        } catch {
            let wsError = WebSocketError.connectionFailed(underlying: error)
            connectionState = .failed(error: wsError)
            throw wsError
        }
    }
    
    // MARK: - handle ping-pong
    
    private func startPingLoop(intervalSeconds: UInt64, maximumConsecutiveFailures: Int) {
        pingTask = Task { [weak self] in
            guard !Task.isCancelled, let self else { return }
            
            var consecutiveFailures = 0
            
            while await self.isConnectedState() && !Task.isCancelled {
                do {
                    try await self.sendPing()
                    consecutiveFailures = 0
                } catch {
                    consecutiveFailures += 1
                }
                
                if consecutiveFailures >= maximumConsecutiveFailures {
                    let error = WebSocketError.keepAliveFailure(consecutiveFailures: consecutiveFailures)
                    await self.handleConnectionLoss(error: error)
                    break
                }
                
                guard !Task.isCancelled else { return }
                
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
    
    // MARK: - receive Messages
    
    /// Starts receiving messages when connected. This task runs until cancelled or connection is lost.
    /// When disconnected, the task exits and should be restarted via connect().
    private func startReceivingMessages() async {
        // Cancel any existing receiving task
        messageReceivingTask?.cancel()
        
        messageReceivingTask = Task { [weak self] in
            guard let self else { return }
            
            // Only receive while connected
            guard await self.isConnectedState() else {
                // Not connected, exit - will be restarted on next connect()
                return
            }
            
            guard let task = await self.webSocketTask else {
                // Task not available, exit
                return
            }
            
            // Receive messages while connected
            while await self.isConnectedState() && !Task.isCancelled {
                do {
                    let message = try await task.receive()
                    self.messageContinuation.yield(message)
                } catch {
                    // If receive fails, propagate the error through the stream
                    // The stream will finish with the error, allowing the client to handle it
                    let wsError = WebSocketError.receiveFailed(underlying: error)
                    self.messageContinuation.finish(throwing: wsError)
                    await self.handleConnectionLoss(error: wsError)
                    break
                }
            }
        }
    }
    
}

extension WebSocketEngine {
    private func isConnectedState() async -> Bool {
        if case .connected = connectionState { return true }
        return false
    }
}
