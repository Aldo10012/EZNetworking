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

        var didDisconnect = false
        let task = Task {
            do {
                try await sut.connect()
                try await sut.disconnect()
                didDisconnect = true
            } catch {
                Issue.record("Unexpected error: \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value

        #expect(didDisconnect)
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

private enum DummyError: Error {
    case error
}
