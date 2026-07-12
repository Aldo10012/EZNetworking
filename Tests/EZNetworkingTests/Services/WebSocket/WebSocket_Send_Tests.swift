@testable import EZNetworking
import Foundation
import Testing

@Suite("Test WebSocket.send()")
final class WebSocketSendTests: WebSocketTestCase {
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
