@testable import EZNetworking
import Foundation
import Testing

/// Shared setup/teardown and helpers for the `WebSocket.*` test suites.
///
/// Each suite subclasses this instead of redefining its own mocks, `getSut()`,
/// and `performConnect(...)` helper. Suites that need a non-default `pingInterval`/
/// `maxPingFailures` or `MockURLSessionWebSocketTask` (e.g. `WebSocketConnectTests`)
/// override `init()` and call `super.init(pingInterval:maxPingFailures:wsTask:)`;
/// the rest inherit the default `init()`.
///
/// `pingConfig` is always built with `pingClock`, a `MockClock`, so the ping loop's
/// delays resolve instantly and tests can assert on the recorded `pingClock.sleptDurations`.
class WebSocketTestCase {
    var pingConfig: PingConfig!
    let pingClock = MockClock()
    var wsTask: MockURLSessionWebSocketTask!
    var urlSession: MockWebSockerURLSession!
    var wsInterceptor: MockWebSocketTaskInterceptor!
    var delegate: SessionDelegate!
    var session: MockSession!

    // MARK: - setup

    init(
        pingInterval: Duration = .seconds(1),
        maxPingFailures: UInt = 1,
        wsTask: MockURLSessionWebSocketTask = MockURLSessionWebSocketTask()
    ) {
        setup(pingInterval: pingInterval, maxPingFailures: maxPingFailures)
        setupSession(withTask: wsTask)
    }

    func setup(pingInterval: Duration, maxPingFailures: UInt) {
        pingConfig = PingConfig(pingInterval: pingInterval, maxPingFailures: maxPingFailures, clock: pingClock)
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

    // MARK: - .connect() helpers

    /// The interceptor event to fire in order to unblock `WebSocket.connect()`, which
    /// suspends inside `waitForConnection()` until the interceptor reports an outcome.
    enum ConnectSimulation {
        case didOpenWithProtocol(String?)
        case didCompleteWithError(any Error)
        case didCloseWithCloseCode(URLSessionWebSocketTask.CloseCode, reason: Data?)
    }

    /// Starts `sut.connect()`, waits for it to reach the suspension point inside
    /// `waitForConnection()`, fires the given interceptor event to unblock it, then
    /// awaits the result. Throws whatever `connect()` throws.
    func performConnect(
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

enum DummyError: Error {
    case error
}
