@testable import EZNetworking
import Foundation
import Testing

@Suite("Test SessionDelegateURLSessionWebSocketDelegate")
final class SessionDelegateURLSessionWebSocketDelegateTests {
    @Test("test SessionDelegate WebSocket DidOpenWithProtocol")
    func sessionDelegateWebSocketDidOpenWithProtocol() {
        let webSocketInterceptor = SpyWebSocketTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.webSocketTaskInterceptor = webSocketInterceptor

        let webSocketTask = mockURLSessionWebSocketTask
        let protocolString = "test-protocol"
        delegate.urlSession(.shared, webSocketTask: webSocketTask, didOpenWithProtocol: protocolString)

        #expect(webSocketInterceptor.didOpenWithProtocol)
        #expect(webSocketInterceptor.receivedProtocol == protocolString)
    }

    @Test("test SessionDelegate WebSocket DidCloseWithCodeAndReason")
    func sessionDelegateWebSocketDidCloseWithCodeAndReason() {
        let webSocketInterceptor = SpyWebSocketTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.webSocketTaskInterceptor = webSocketInterceptor

        let closeCode: URLSessionWebSocketTask.CloseCode = .goingAway
        let reasonData = "Closed by server".data(using: .utf8)
        delegate.urlSession(.shared, webSocketTask: mockURLSessionWebSocketTask, didCloseWith: closeCode, reason: reasonData)

        #expect(webSocketInterceptor.didCloseWithCodeAndReason)
        #expect(webSocketInterceptor.receivedCloseCode == closeCode)
        #expect(webSocketInterceptor.receivedReason == reasonData)
    }

    @Test("test SessionDelegate WebSocket didCompleteWithError")
    func sessionDelegateWebSocketDidCompleteWithError() {
        let webSocketInterceptor = SpyWebSocketTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.webSocketTaskInterceptor = webSocketInterceptor

        let error = NSError(domain: "test", code: 0)
        delegate.urlSession(.shared, task: mockURLSessionWebSocketTask, didCompleteWithError: error)

        #expect(webSocketInterceptor.didCompleteWithError)
        #expect(webSocketInterceptor.receivedError as? NSError == error)
    }
}

// MARK: mock class

private class SpyWebSocketTaskInterceptor: WebSocketTaskInterceptor {
    var onEvent: ((WebSocketTaskEvent) -> Void)? = { _ in }

    var didOpenWithProtocol = false
    var receivedProtocol: String?
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        didOpenWithProtocol = true
        receivedProtocol = `protocol`
    }

    var didCompleteWithError = false
    var receivedError: Error?
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: any Error) {
        didCompleteWithError = true
        receivedError = error
    }

    var didCloseWithCodeAndReason = false
    var receivedCloseCode: URLSessionWebSocketTask.CloseCode?
    var receivedReason: Data?
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        didCloseWithCodeAndReason = true
        receivedCloseCode = closeCode
        receivedReason = reason
    }
}

// MARK: mock variables

private var mockURLSessionWebSocketTask: URLSessionWebSocketTask {
    URLSession.shared.webSocketTask(with: URL(string: "wss://www.example.com")!)
}
