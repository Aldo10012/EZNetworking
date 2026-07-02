@testable import EZNetworking
import Foundation
import Testing

// MARK: .connect()

@Suite("Test WebSocket.connect()")
final class WebSocketConnectTests {
    var pingConfig: PingConfig!
    var wsTask: MockURLSessionWebSocketTask!
    var urlSession: MockWebSockerURLSession!
    var wsInterceptor: MockWebSocketTaskInterceptor!
    var delegate: SessionDelegate!
    var session: MockSession!

    // MARK: - setup

    init() {
        self.setup(pingConfig: PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 0))
        self.setupSession(withTask: MockURLSessionWebSocketTask())
    }

    func setup(pingConfig: PingConfig) {
        self.pingConfig = pingConfig
    }

    func setupSession(withTask wsTask: MockURLSessionWebSocketTask) {
        self.wsTask = wsTask
        self.urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        self.wsInterceptor = MockWebSocketTaskInterceptor()
        self.delegate = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        self.session = MockSession(urlSession: urlSession, delegate: delegate)
    }

    func getSut() -> WebSocket {
        return WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: session)
    }

    // MARK: - teardown

    deinit {
        self.wsTask = nil
        self.urlSession = nil
        self.wsInterceptor = nil
        self.delegate = nil
        self.session = nil
    }

    // MARK: .connect()

    @Test("test calling .connect succeeds")
    func callingConnectDoesNotThrow() async throws {
        let sut = getSut()
        try await performConnect(sut, simulating: .didOpenWithProtocol(nil))
    }

    @Test("test calling .connect throws error if WebSocketTaskInterceptor didCompleteWithError")
    func callingConnectThrowsErrorIfInterceptorDidCompleteWithError() async throws {
        let sut = getSut()

        var errorThrown: NetworkingError?
        do {
            try await performConnect(sut, simulating: .didCompleteWithError(DummyError.error))
            Issue.record("Unexpected success")
        } catch let error as NetworkingError {
            errorThrown = error
        } catch {
            Issue.record("Expected NetworkingError")
        }

        #expect(errorThrown == .webSocketFailed(reason: .connectionFailed(underlying: DummyError.error)))
    }

    @Test("test calling .connect throws error if WebSocketTaskInterceptor didClsoeWithCode")
    func callingConnectThrowsErrorIfInterceptorDidCloseWithCode() async throws {
        let sut = getSut()

        var errorThrown: NetworkingError?
        do {
            try await performConnect(sut, simulating: .didCloseWithCloseCode(.internalServerError, reason: nil))
            Issue.record("Unexpected success")
        } catch let error as NetworkingError {
            errorThrown = error
        } catch {
            Issue.record("Expected NetworkingError")
        }

        #expect(errorThrown == .webSocketFailed(reason: .unexpectedDisconnection(code: .internalServerError, reason: nil)))
    }

    @Test("test calling .connect does call .webSocketTaskInspectable()")
    func callingConnectDoesCallWebSocketTaskInspectable() async throws {
        let sut = getSut()

        try await performConnect(sut, simulating: .didOpenWithProtocol(nil))
        #expect(urlSession.didCallWebSocketTaskInspectable)
    }

    @Test("test calling .connect does call URLSessionWebSocketTask.resume()")
    func callingConnectDoesCallURLSessionWebSocketTaskResume() async throws {
        let sut = getSut()

        try await performConnect(sut, simulating: .didOpenWithProtocol(nil))
        #expect(wsTask.didCallResume)
    }

    @Test("test calling .connect does call URLSessionWebSocketTask.sendPing()")
    func callingConnectDoesCallURLSessionWebSocketTaskSendPing() async throws {
        let sut = getSut()

        try await performConnect(sut, simulating: .didOpenWithProtocol(nil))
        try await Task.sleep(nanoseconds: 1_500_000_000)

        #expect(wsTask.didCallSendPing)
    }

    // MARK: .connect() + ping pong

    @Test("test calling .connect fails if ping does not receive pong after 3 failed attempts")
    func callingConnectFailsIfPingDoesNotReceivePongAfter3FailedAttempts() async throws {
        setup(pingConfig: PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 3))
        setupSession(withTask: MockURLSessionWebSocketTask(pingThrowsError: true))
        let sut = getSut()

        try await performConnect(sut, simulating: .didOpenWithProtocol(nil), sleepNanoseconds: 1_000_000_000)
        try await Task.sleep(nanoseconds: 1_000_000_000)

        #expect(wsTask.pingFailureCount == 3)
    }

    @Test("test captured error from calling .connect if ping does not receive pong")
    func capturedErrorFromCallingConnectIfPingDoesNotReceivePong() async throws {
        setup(pingConfig: PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 1))
        setupSession(withTask: MockURLSessionWebSocketTask(pingThrowsError: true))
        let sut = getSut()

        try await performConnect(sut, simulating: .didOpenWithProtocol(nil))
        try await Task.sleep(nanoseconds: 1_000_000_000)

        #expect(wsTask.pingError as? MockURLSessionWebSocketTaskError == MockURLSessionWebSocketTaskError.pingError)
    }
}

// MARK: Helpers

/// The interceptor event to fire in order to unblock `WebSocket.connect()`, which
/// suspends inside `waitForConnection()` until the interceptor reports an outcome.
fileprivate enum ConnectSimulation {
    case didOpenWithProtocol(String?)
    case didCompleteWithError(any Error)
    case didCloseWithCloseCode(URLSessionWebSocketTask.CloseCode, reason: Data?)
}

extension WebSocketConnectTests {
    /// Starts `sut.connect()`, waits for it to reach the suspension point inside
    /// `waitForConnection()`, fires the given interceptor event to unblock it, then
    /// awaits the result. Throws whatever `connect()` throws.
    fileprivate func performConnect(
        _ sut: WebSocket,
        simulating simulation: ConnectSimulation,
        sleepNanoseconds: UInt64 = 100
    ) async throws {
        let task = try createConnectTaskExpectingThrow(sut)

        try await Task.sleep(nanoseconds: sleepNanoseconds)
        switch simulation {
        case .didOpenWithProtocol(let proto):
            wsInterceptor.simulateOpenWithProtocol(proto)
        case .didCompleteWithError(let error):
            wsInterceptor.simulateDidCompleteWithError(error: error)
        case .didCloseWithCloseCode(let code, let reason):
            wsInterceptor.simulateDidCloseWithCloseCode(didCloseWith: code, reason: reason)
        }

        try await task.value
    }

    func createConnectTaskExpectingThrow(_ sut: WebSocket) throws -> Task<Void, Error> {
        Task {
            do {
                try await sut.connect()
            } catch {
                throw error
            }
        }
    }
}

private enum DummyError: Error {
    case error
}
