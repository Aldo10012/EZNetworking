import Foundation
import Testing
@testable import EZNetworking

@Suite("Test WebSocketTaskProtocol")
final class WebSocketTaskProtocolTest {
    @Test("test calling sendPing() async/await method calls the callback method")
    func testSendPing() async throws {
        let sut = SpyWebSocketTaskProtocol(pingShouldThrow: false)

        try await sut.sendPing()
        #expect(sut.didCallSendPing)
    }

    @Test("test calling sendPing() async/await method when not throwing error")
    func sendPingWhenNotThrowingError() async throws {
        let sut = SpyWebSocketTaskProtocol(pingShouldThrow: false)

        await #expect(throws: Never.self) {
            try await sut.sendPing()
        }
    }

    @Test("test calling sendPing() async/await method when throwing error")
    func sendPingWhenThrowingError() async throws {
        let sut = SpyWebSocketTaskProtocol(pingShouldThrow: true)

        await #expect(throws: DummyPingError.error) {
            try await sut.sendPing()
        }
    }
}

private class SpyWebSocketTaskProtocol: WebSocketTaskProtocol {
    var pingShouldThrow: Bool

    init(pingShouldThrow: Bool) {
        self.pingShouldThrow = pingShouldThrow
    }

    var didCallSendPing = false
    func sendPing(pongReceiveHandler: @escaping @Sendable ((any Error)?) -> Void) {
        didCallSendPing = true

        pongReceiveHandler(pingShouldThrow ? DummyPingError.error : nil)
    }

    // not relevant to unit test

    var closeCode: URLSessionWebSocketTask.CloseCode = .goingAway
    var closeReason: Data?
    func resume() {}
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {}
    func send(_ message: URLSessionWebSocketTask.Message) async throws {}
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping @Sendable ((any Error)?) -> Void) {}
    func receive() async throws -> URLSessionWebSocketTask.Message { .string("") }
    func receive(completionHandler: @escaping @Sendable (Result<URLSessionWebSocketTask.Message, any Error>) -> Void) {}
}

private enum DummyPingError: Error {
    case error
}
