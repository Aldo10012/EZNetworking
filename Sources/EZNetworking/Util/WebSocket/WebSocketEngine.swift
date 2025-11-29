import Foundation

public actor WebSocketEngine: WebSocketClient {
    
    // MARK: - Dependencies
    
    private let urlSession: URLSessionTaskProtocol
    private var sessionDelegate: SessionDelegate
    private let webSocketRequest: URLRequest
    private let pingConfic: PingConfig
    
    // MARK: - WS interceptor
    
    private let defaultWebSocketTaskInterceptor: WebSocketTaskInterceptor = DefaultWebSocketTaskInterceptor()
    
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
        pingConfic: PingConfig = PingConfig(),
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        sessionDelegate: SessionDelegate? = nil
    ) {
        self.webSocketRequest = urlRequest
        self.pingConfic = pingConfic
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
        
        connectionState = .connecting
        
        // TODO: add wait for connection to be established
        // TODO: start ping-long loop
    }
    
    // MARK: - disconnect
    
    public func disconnect(closeCode: URLSessionWebSocketTask.CloseCode?, reason: Data?) async {
        // TODO: implement
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
    
    
    
    // MARK: - handle ping-pong
}
