@testable import EZNetworking
import Foundation
import Testing

// MARK: .connect()

@Suite("Test WebSocket.connect()")
final class WebSocketConnectTests: WebSocketTestCase {
    init() {
        super.init(pingConfig: PingConfig(pingInterval: .nanoseconds(1), maxPingFailures: 0))
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
