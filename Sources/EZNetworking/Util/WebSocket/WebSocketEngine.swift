import Foundation

public actor WebSocketEngine: WebSocketClient {
    
    // MARK: - Dependencies
    
    private let urlSession: URLSessionTaskProtocol
    private var sessionDelegate: SessionDelegate
    private let webSocketRequest: URLRequest
    private let pingConfig: PingConfig
    
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
        
    private var messageContinuation: AsyncThrowingStream<InboundMessage, WebSocketError>.Continuation?
    private var messageStreamCreated = false
    
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
    }
    
    // MARK: - deinit
    
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
        
        messageContinuation?.finish()
        messageContinuation = nil
        messageStreamCreated = false
        
        webSocketTask?.cancel(with: closeCode, reason: reason)
        webSocketTask = nil
        
        connectionState = newState
    }
    
    // MARK: - send
    
    public func send(_ message: OutboundMessage) async throws {
        // TODO: implement
    }
    
    // MARK: - messages
    
    public nonisolated func messages() -> AsyncThrowingStream<InboundMessage, Error> {
        // TODO: implement
        AsyncThrowingStream<InboundMessage, Error> { $0.finish() }
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
        Task { [weak self] in
            guard let self else { return }
            
            var consecutiveFailures = 0
            
            while await self.isConnectedState() {
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
