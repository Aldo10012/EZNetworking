@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocket.send()")
final class WebSocketSendTests {
    @Test("test string message successfully send after connection is made")
    func sendingMessageSuccessfullyIfSentAfterConnect() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        var didSend = false

        let task = Task {
            do {
                try await sut.connect()
                try await sut.send(.string("test send"))
                didSend = true
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value
        #expect(didSend)
    }

    @Test("test string message fails if send without connecting first")
    func sendingMessageFailsIfSentWithoutConnectingFirst() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        var capturedError: WebSocketError?
        let task = Task {
            do {
                try await sut.send(.string("test send"))
                Issue.record("Should no tbe able to send without calling .connect() first")
            } catch let wsError as WebSocketError {
                capturedError = wsError
            } catch {
                Issue.record("Expected WebSocketError")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)

        await task.value
        #expect(capturedError == .notConnected)
    }

    @Test("test string message fails if send() throws error")
    func sendingMessageFailsIfSendThrowsError() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask(sendThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        var capturedError: WebSocketError?
        let task = Task {
            do {
                try await sut.connect()
                try await sut.send(.string("test send"))
                Issue.record("Expected .send() to fail")
            } catch let wsError as WebSocketError {
                capturedError = wsError
            } catch {
                Issue.record("Expected WebSocketError")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value
        #expect(capturedError == .sendFailed(underlying: MockURLSessionWebSocketTaskError.failedToSendMessage))
    }
}

private enum DummyError: Error {
    case error
}
