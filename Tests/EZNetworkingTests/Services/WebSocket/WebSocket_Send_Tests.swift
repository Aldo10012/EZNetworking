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

    // MARK: .send()

    @Test("test string message successfully send after connection is made")
    func sendingMessageSuccessfullyIfSentAfterConnect() async throws {
        let sut = getSut()

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

        var capturedError: NetworkingError?
        let task = Task {
            do {
                try await sut.connect()
                try await sut.send(.string("test send"))
                Issue.record("Expected .send() to fail")
            } catch let error as NetworkingError {
                capturedError = error
            } catch {
                Issue.record("Expected WebSocketError")
            }
        }

        try await Task.sleep(nanoseconds: 100)
        wsInterceptor.simulateOpenWithProtocol(nil)
        await task.value
        #expect(capturedError == .webSocketFailed(reason: .sendFailed(underlying: MockURLSessionWebSocketTaskError.failedToSendMessage)))
    }
}

private enum DummyError: Error {
    case error
}
