import Foundation
import EZNetworking

class MockURLSessionWebSocketTask: WebSocketTaskProtocol {

    init(resumeClosure: @escaping (() -> Void) = {}) {
        self.resumeClosure = resumeClosure
    }
    
    // MARK: resume()
    
    var resumeClosure: () -> Void
    var didCallResume = false
    func resume() {
        didCallResume = true
        resumeClosure()
    }

    var didCallCancel = false
    var didCancelWithCloseCode: URLSessionWebSocketTask.CloseCode?
    var didCancelWithReason: Data?
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        didCallCancel = true
        didCancelWithCloseCode = closeCode
        didCancelWithReason = reason
    }

    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping @Sendable ((any Error)?) -> Void) { }

    func send(_ message: URLSessionWebSocketTask.Message) async throws {}

    func receive(completionHandler: @escaping @Sendable (Result<URLSessionWebSocketTask.Message, any Error>) -> Void) { }

    func receive() async throws -> URLSessionWebSocketTask.Message { .string("") }

    // MARK: sendPing
    
    var shouldFailPing: Bool = false
    var pingFailureCount: Int = 0
    func sendPing(pongReceiveHandler: @escaping @Sendable ((any Error)?) -> Void) {
        if shouldFailPing {
            pingFailureCount += 1
            pongReceiveHandler(NSError(domain: "MockPingError", code: 1))
        } else {
            pongReceiveHandler(nil)
        }
    }
}
