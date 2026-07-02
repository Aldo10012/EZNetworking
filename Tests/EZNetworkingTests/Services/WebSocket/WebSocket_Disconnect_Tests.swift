@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocket.disconnect()")
final class WebSocketDisconnectTests {
    var pingConfig: PingConfig!
    var wsTask: MockURLSessionWebSocketTask!
    var urlSession: MockWebSockerURLSession!
    var wsInterceptor: MockWebSocketTaskInterceptor!
    var delegate: SessionDelegate!
    var session: MockSession!

    // MARK: - setup

    init() {
        self.setup(pingConfig: PingConfig(pingInterval: .seconds(1), maxPingFailures: 1))
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

    // MARK: .disconnect()

    @Test("test calling .disconnect() does call WebSocketTask.cancel()")
    func callingDisconnectDoesCallWebSocketTaskCancel() async throws {
        let sut = getSut()

        try await performConnect(sut, simulating: .didOpenWithProtocol(nil))
        try await sut.disconnect()

        #expect(wsTask.didCallCancel == true)
        #expect(wsTask.didCancelWithCloseCode == .normalClosure)
        #expect(wsTask.didCancelWithReason == nil)
    }

    @Test("test calling .disconnect() throws if did not call .connect() first")
    func callingDisconnectFailsIfNotConnected() async throws {
        let sut = getSut()

        var disconnectDidThrow = false
        do {
            try await sut.disconnect()
            Issue.record("Unexpectedly disconnected without error")
        } catch {
            disconnectDidThrow = true
        }
        #expect(disconnectDidThrow)
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

extension WebSocketDisconnectTests {
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
