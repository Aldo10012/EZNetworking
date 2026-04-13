@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DefaultWebSocketTaskInterceptor")
final class DefaultWebSocketTaskInterceptorTests {
    @Test("calls onEvent when didOpenWithProtocol is invoked")
    func didOpenCallsOnEvent() {
        let url = URL(string: "wss://example.com/socket")!
        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: url)

        var received: WebSocketTaskEvent?
        let interceptor = DefaultWebSocketTaskInterceptor { event in
            received = event
        }

        interceptor.urlSession(session, webSocketTask: task, didOpenWithProtocol: "chat")

        guard case let .didOpenWithProtocol(proto) = received else {
            #expect(Bool(false))
            return
        }
        #expect(proto == "chat")
    }

    @Test("calls onEvent when didCloseWith is invoked with code and reason")
    func didCloseCallsOnEvent() {
        let url = URL(string: "wss://example.com/socket")!
        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: url)

        var received: WebSocketTaskEvent?
        let interceptor = DefaultWebSocketTaskInterceptor { event in
            received = event
        }

        let reason = "bye".data(using: .utf8)
        interceptor.urlSession(session, webSocketTask: task, didCloseWith: .normalClosure, reason: reason)

        guard case let .didClose(code, data) = received else {
            #expect(Bool(false))
            return
        }
        #expect(code == .normalClosure)
        #expect(data == reason)
    }

    @Test("default init does not crash and onEvent is mutable")
    func defaultInitAndOnEventMutation() {
        let url = URL(string: "wss://example.com/socket")!
        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: url)

        let interceptor = DefaultWebSocketTaskInterceptor()

        var called = false
        interceptor.onEvent = { _ in
            called = true
        }

        interceptor.urlSession(session, webSocketTask: task, didOpenWithProtocol: nil)
        #expect(called == true)
    }

    @Test("calls onEvent when task:didCompleteWithError is invoked")
    func didCompleteWithErrorCallsOnEvent() {
        let url = URL(string: "wss://example.com/socket")!
        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: url)

        var received: WebSocketTaskEvent?
        let interceptor = DefaultWebSocketTaskInterceptor { event in
            received = event
        }

        let error = URLError(.timedOut)
        interceptor.urlSession(session, task: task, didCompleteWithError: error)

        guard case let .didOpenWithError(err) = received else {
            #expect(Bool(false))
            return
        }
        let receivedNSError = err as NSError
        let expectedNSError = error as NSError
        #expect(receivedNSError.domain == expectedNSError.domain)
        #expect(receivedNSError.code == expectedNSError.code)
    }
}
