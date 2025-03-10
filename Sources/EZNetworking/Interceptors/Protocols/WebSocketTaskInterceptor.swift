import Foundation

/// Protocol for intercepting WebSocket tasks specifically.
public protocol WebSocketTaskInterceptor: AnyObject {
    /// Intercepts when a WebSocket task opens with a protocol.
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?)

    /// Intercepts when a WebSocket task closes with a code and reason.
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}
