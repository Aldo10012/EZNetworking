@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocket.disconnect()")
final class WebSocketDisconnectTests {
    @Test("test calling .disconnect() does call WebSocketTask.cancel()")
    func callingDisconnectDoesCallWebSocketTaskCancel() async throws {
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

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
        let pingConfig = PingConfig(pingInterval: .seconds(1), maxPingFailures: 1)
        let wsTask = MockURLSessionWebSocketTask()
        let urlSession = MockWebSockerURLSession(webSocketTask: wsTask)
        let wsInterceptor = MockWebSocketTaskInterceptor()
        let session = SessionDelegate(webSocketTaskInterceptor: wsInterceptor)
        let sut = WebSocket(request: webSocketRequest, pingConfig: pingConfig, session: MockSession(urlSession: urlSession, delegate: session))

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
