@testable import EZNetworking
import Foundation
import Testing

// MARK: .connect()

@Suite("Test WebSocket.connect()")
final class WebSocketConnectTests {
    @Test("test calling .connect succeeds")
    func callingConnectDoesNotThrow() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, session: MockSession(urlSession: urlSession, delegate: session))

        var didConnect = false

        let task = Task {
            do {
                try await sut.connect()
                didConnect = true
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        #expect(didConnect)
    }

    @Test("test calling .connect throws error if WebSocketTaskInterceptor didCompleteWithError")
    func callingConnectThrowsErrorIfInterceptorDidCompleteWithError() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, session: MockSession(urlSession: urlSession, delegate: session))

        var errorThrown: NetworkingError?

        let task = Task {
            do {
                try await sut.connect()
                Issue.record("Unexpected success")
            } catch let error as NetworkingError {
                errorThrown = error
            } catch {
                Issue.record("Expected NetworkingError")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateDidCompleteWithError(error: DummyError.error)
        await task.value

        #expect(errorThrown == .webSocketFailed(reason: .connectionFailed(underlying: DummyError.error)))
    }

    @Test("test calling .connect throws error if WebSocketTaskInterceptor didClsoeWithCode")
    func callingConnectThrowsErrorIfInterceptorDidCloseWithCode() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, session: MockSession(urlSession: urlSession, delegate: session))

        var errorThrown: NetworkingError?

        let task = Task {
            do {
                try await sut.connect()
                Issue.record("Unexpected success")
            } catch let error as NetworkingError {
                errorThrown = error
            } catch {
                Issue.record("Expected NetworkingError")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateDidCloseWithCloseCode(didCloseWith: .internalServerError, reason: nil)
        await task.value

        #expect(errorThrown == .webSocketFailed(reason: .unexpectedDisconnection(code: .internalServerError, reason: nil)))
    }

    @Test("test calling .connect does call .webSocketTaskInspectable()")
    func callingConnectDoesCallWebSocketTaskInspectable() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, session: MockSession(urlSession: urlSession, delegate: session))

        let task = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        #expect(urlSession.didCallWebSocketTaskInspectable)
    }

    @Test("test calling .connect does call URLSessionWebSocketTask.resume()")
    func callingConnectDoesCallURLSessionWebSocketTaskResume() async throws {
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, session: MockSession(urlSession: urlSession, delegate: session))

        let task = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        #expect(wsTask.didCallResume)
    }
}

// MARK: .connect() + ping pong

@Suite("Test WebSocket.connect() with ping pont")
final class WebSocketConnectPingPongTests {
    @Test("test calling .connect does call URLSessionWebSocketTask.sendPing()")
    func callingConnectDoesCallURLSessionWebSocketTaskSendPing() async throws {
        let pingConfig = PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 0)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        let task = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        try await Task.sleep(nanoseconds: 1_500_000_000)

        #expect(wsTask.didCallSendPing)
    }

    @Test("test calling .connect fails if ping does not receive pong after 3 failed attempts")
    func callingConnectFailsIfPingDoesNotReceivePongAfter3FailedAttempts() async throws {
        let pingConfig = PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 3)
        let wsTask = MockURLSessionWebSocketTask(pingThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        let task = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        try await Task.sleep(nanoseconds: 1_000_000_000)

        #expect(wsTask.pingFailureCount == 3)
    }

    @Test("test captured error from calling .connect if ping does not receive pong")
    func capturedErrorFromCallingConnectIfPingDoesNotReceivePong() async throws {
        let pingConfig = PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask(pingThrowsError: true)
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

        let task = Task {
            do {
                try await sut.connect()
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        try await Task.sleep(nanoseconds: 1_000_000_000)

        #expect(wsTask.pingError as? MockURLSessionWebSocketTaskError == MockURLSessionWebSocketTaskError.pingError)
    }
}

private enum DummyError: Error {
    case error
}
