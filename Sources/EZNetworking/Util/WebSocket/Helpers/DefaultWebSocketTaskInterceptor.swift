import Foundation

internal class DefaultWebSocketTaskInterceptor: WebSocketTaskInterceptor {
    var onEvent: (WebSocketTaskEvent) -> Void
    
    init(onEvent: @escaping (WebSocketTaskEvent) -> Void = { _ in }) {
        self.onEvent = onEvent
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        onEvent(.didOpenWithProtocol(protocolStr: `protocol`))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: any Error) {
        onEvent(.didOpenWithError(error: error))
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        onEvent(.didClose(code: closeCode, reason: reason))
    }
}
