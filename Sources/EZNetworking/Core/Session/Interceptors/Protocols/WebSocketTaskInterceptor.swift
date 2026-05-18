import Foundation

/// Protocol for intercepting WebSocket tasks specifically.
public protocol WebSocketTaskInterceptor: AnyObject {
    var onEvent: (@Sendable (WebSocketTaskEvent) -> Void)? { get set }

    /// Intercepts when a WebSocket task opens with a protocol.
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?)

    /// Intercepts when a WebSocket task closes with a code and reason.
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)

    /// Intercepts when a task completes with  an error.
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error)
}

public enum WebSocketTaskEvent: Sendable {
    case didOpenWithProtocol(protocolStr: String?)
    case didOpenWithError(error: SendableError)
    case didClose(code: URLSessionWebSocketTask.CloseCode, reason: Data?)
}
