@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocket.send()")
final class WebSocketSendTests {
    var pingConfig: PingConfig!
    var wsTask: MockURLSessionWebSocketTask!
    var urlSession: MockWebSockerURLSession!
    var wsInterceptor: MockWebSocketTaskInterceptor!
    var delegate: SessionDelegate!
    var session: MockSession!

    // MARK: - setup

    init() {
        setup(pingConfig: PingConfig(pingInterval: .seconds(1), maxPingFailures: 1))
        setupSession(withTask: MockURLSessionWebSocketTask())
    }

    func setup(pingConfig: PingConfig) {
        self.pingConfig = pingConfig
    }

    func setupSession(withTask wsTask: MockURLSessionWebSocketTask) {
        self.wsTask = wsTask
        urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        wsInterceptor = MockWebSocketTaskInterceptor()
        delegate = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        session = MockSession(urlSession: urlSession, delegate: delegate)
    }

    func getSut() -> WebSocket {
        WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: session)
    }

    // MARK: - teardown

    deinit {
        self.wsTask = nil
        self.urlSession = nil
        self.wsInterceptor = nil
        self.delegate = nil
        self.session = nil
    }

    // MARK: .send()

    @Test("test string message successfully send after connection is made")
    func sendingMessageSuccessfullyIfSentAfterConnect() async throws {
        let sut = getSut()

        try await performConnect(sut, simulating: .didOpenWithProtocol(nil))
        try await sut.send(.string("test send"))
    }

    @Test("test string message fails if send without connecting first")
    func sendingMessageFailsIfSentWithoutConnectingFirst() async throws {
        let sut = getSut()

        var capturedError: NetworkingError?
        let task = Task {
            do {
                try await sut.send(.string("test send"))
                Issue.record("Should no tbe able to send without calling .connect() first")
            } catch let error as NetworkingError {
                capturedError = error
            } catch {
                Issue.record("Expected NetworkingError")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)

        await task.value
        #expect(capturedError == .webSocketFailed(reason: .notConnected))
    }

    @Test("test string message fails if send() throws error")
    func sendingMessageFailsIfSendThrowsError() async throws {
        setupSession(withTask: MockURLSessionWebSocketTask(sendThrowsError: true))
        let sut = getSut()

        try await performConnect(sut, simulating: .didOpenWithProtocol(nil))

        var capturedError: NetworkingError?
        do {
            try await sut.send(.string("test send"))
            Issue.record("Expected .send() to fail")
        } catch let error as NetworkingError {
            capturedError = error
        } catch {
            Issue.record("Expected WebSocketError")
        }
        #expect(capturedError == .webSocketFailed(reason: .sendFailed(underlying: MockURLSessionWebSocketTaskError.failedToSendMessage)))
    }
}

// MARK: Helpers

/// The interceptor event to fire in order to unblock `WebSocket.connect()`, which
/// suspends inside `waitForConnection()` until the interceptor reports an outcome.
private enum ConnectSimulation {
    case didOpenWithProtocol(String?)
    case didCompleteWithError(any Error)
    case didCloseWithCloseCode(URLSessionWebSocketTask.CloseCode, reason: Data?)
}

extension WebSocketSendTests {
    /// Starts `sut.connect()`, waits for it to reach the suspension point inside
    /// `waitForConnection()`, fires the given interceptor event to unblock it, then
    /// awaits the result. Throws whatever `connect()` throws.
    private func performConnect(
        _ sut: WebSocket,
        simulating simulation: ConnectSimulation,
        sleepNanoseconds: UInt64 = 100
    ) async throws {
        let task = try createConnectTaskExpectingThrow(sut)

        try await Task.sleep(nanoseconds: sleepNanoseconds)
        switch simulation {
        case let .didOpenWithProtocol(proto):
            wsInterceptor.simulateOpenWithProtocol(proto)
        case let .didCompleteWithError(error):
            wsInterceptor.simulateDidCompleteWithError(error: error)
        case let .didCloseWithCloseCode(code, reason):
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
