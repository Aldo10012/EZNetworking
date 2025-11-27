import Foundation
import EZNetworking

class MockURLSessionWebSocketTask: WebSocketTaskProtocol {
    init() {}

    func resume() {}

    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {}

    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping @Sendable ((any Error)?) -> Void) { }

    func send(_ message: URLSessionWebSocketTask.Message) async throws {}

    func receive(completionHandler: @escaping @Sendable (Result<URLSessionWebSocketTask.Message, any Error>) -> Void) { }

    func receive() async throws -> URLSessionWebSocketTask.Message { .string("") }

    func sendPing(pongReceiveHandler: @escaping @Sendable ((any Error)?) -> Void) { }
}
