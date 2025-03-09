import Foundation

extension SessionDelegate: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession,
                          webSocketTask: URLSessionWebSocketTask,
                          didOpenWithProtocol protocol: String?) {
        webSocketTaskInterceptor?.urlSession(session, webSocketTask: webSocketTask, didOpenWithProtocol: `protocol`)
    }
    
    public func urlSession(_ session: URLSession,
                          webSocketTask: URLSessionWebSocketTask,
                          didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                          reason: Data?) {
        webSocketTaskInterceptor?.urlSession(session, webSocketTask: webSocketTask, didCloseWith: closeCode, reason: reason)
    }
}
