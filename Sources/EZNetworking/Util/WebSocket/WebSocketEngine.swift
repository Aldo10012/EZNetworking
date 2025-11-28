import Foundation

public actor WebSocketEngine: WebSocketClient {
    
    // MARK: - variables
    
    // Dependencies
    
    private let urlSession: URLSessionTaskProtocol
    private var sessionDelegate: SessionDelegate
    private let urlRequest: URLRequest
    private let pingConfic: PingConfig
    
    // Default web socket interceptor
    
    private let defaultWebSocketTaskInterceptor: WebSocketTaskInterceptor = DefaultWebSocketTaskInterceptor()
    
    // WebSocket Task
    
    private var webSocketTask: WebSocketTaskProtocol?
    
    // MARK: - init
    
    public init(
        urlRequest: URLRequest,
        pingConfic: PingConfig = PingConfig(),
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        sessionDelegate: SessionDelegate? = nil
    ) {
        self.urlRequest = urlRequest
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
    }
    
    // MARK: - state change observation
    
    public nonisolated var stateChanges: AsyncStream<WebSocketConnectionState> {
        // TODO: implement
        AsyncStream<WebSocketConnectionState> { $0.finish() }
    }
    
    // MARK: - connect
    
    public func connect() async throws {
        // TODO: implement
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
