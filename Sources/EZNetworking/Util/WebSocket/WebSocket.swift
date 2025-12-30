import Foundation

public actor WebSocket: WebSocketClient {
    
    private let urlSession: URLSessionTaskProtocol
    private var sessionDelegate: SessionDelegate
    private let webSocketRequest: URLRequest
    
    // MARK: Init
    
    public init(
        urlRequest: URLRequest,
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        sessionDelegate: SessionDelegate? = nil
    ) {
        self.webSocketRequest = urlRequest
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
    
    public nonisolated var stateChanges: AsyncStream<WebSocketConnectionState> {
        // TODO: implement
        AsyncStream<WebSocketConnectionState> { $0.finish() }
    }
    
    public func connect() async throws {
        // TODO: implement
    }
    
    public func disconnect(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async {
        // TODO: implement
    }
    
    public func send(_ message: OutboundMessage) async throws {
        // TODO: implement
    }
    
    public nonisolated func messages() -> AsyncThrowingStream<InboundMessage, any Error> {
        // TODO: implement
        AsyncThrowingStream<InboundMessage, Error> { $0.finish() }
    }
}
