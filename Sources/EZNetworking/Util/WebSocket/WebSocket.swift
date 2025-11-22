import Foundation

/// Messages sent to the WebSocket
public typealias OutboundMessage = URLSessionWebSocketTask.Message

/// Messages received from the WebSocket
public typealias InboundMessage = URLSessionWebSocketTask.Message

public protocol WebSocketClient {
    /// Connect to the WebSocket server
    func connect()
    
    /// Disconnect from the WebSocket server
    func disconnect()
    
    /// Send a message (string or binary) to the WebSocket
    func send(_ message: OutboundMessage) async throws
}

public class WebSocketClientImpl: WebSocketClient {
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private let requestDecoder: RequestDecodable
    private var sessionDelegate: SessionDelegate
    
    private let fallbackDownloadTaskInterceptor: WebSocketTaskInterceptor = DefaultWebSocketTaskInterceptor()
    
    // MARK: init
    
    public init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        validator: ResponseValidator = ResponseValidatorImpl(),
        requestDecoder: RequestDecodable = RequestDecoder(),
        sessionDelegate: SessionDelegate? = nil // Now optional!
    ) {
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
        self.validator = validator
        self.requestDecoder = requestDecoder
    }
    
    // MARK: WebSocket
    
    public func connect() {
        // TODO: implement
    }
    
    public func disconnect() {
        // TODO: implement
    }
    
    public func send(_ message: OutboundMessage) async throws {
        // TODO: implement
    }
}

internal class DefaultWebSocketTaskInterceptor: WebSocketTaskInterceptor {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        // TODO: implement
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        // TODO: implement
    }
}
