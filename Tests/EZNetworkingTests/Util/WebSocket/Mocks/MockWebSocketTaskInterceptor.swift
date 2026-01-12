import EZNetworking
import Foundation

let webSocketUrl = URL(string: "ws://127.0.0.1:8080/example")!
var webSocketRequest: WebSocketRequest { WebSocketRequest(url: webSocketUrl.absoluteString) }

class MockWebSocketTaskInterceptor: WebSocketTaskInterceptor {
    private let session = URLSession.shared
    private lazy var task: URLSessionWebSocketTask = session.webSocketTask(with: webSocketUrl, protocols: [])

    var onEvent: ((WebSocketTaskEvent) -> Void)?

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        onEvent?(.didOpenWithProtocol(protocolStr: `protocol`))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: any Error) {
        onEvent?(.didOpenWithError(error: error))
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        onEvent?(.didClose(code: closeCode, reason: reason))
    }

    // simulate methods

    func simulateOpenWithProtocol(_ proto: String?) {
        urlSession(session, webSocketTask: task, didOpenWithProtocol: proto)
    }

    func simulateDidCompleteWithError(error: any Error) {
        urlSession(session, task: task, didCompleteWithError: error)
    }

    func simulateDidCloseWithCloseCode(didCloseWith: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        urlSession(session, webSocketTask: task, didCloseWith: didCloseWith, reason: reason)
    }
}
