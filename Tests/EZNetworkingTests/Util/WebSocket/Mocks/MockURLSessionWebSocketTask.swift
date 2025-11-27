import Foundation
import EZNetworking

class MockURLSessionWebSocketTask: WebSocketTaskProtocol {

    init(resumeClosure: @escaping (() -> Void) = {},
         sendThrowsError: Bool = false) {
        self.resumeClosure = resumeClosure
        self.sendThrowsError = sendThrowsError
    }
    
    // MARK: resume()
    
    var resumeClosure: () -> Void
    var didCallResume = false
    func resume() {
        didCallResume = true
        resumeClosure()
    }

    // MARK: cancel()
    
    var didCallCancel = false
    var didCancelWithCloseCode: URLSessionWebSocketTask.CloseCode?
    var didCancelWithReason: Data?
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        didCallCancel = true
        didCancelWithCloseCode = closeCode
        didCancelWithReason = reason
    }

    // MARK: send()
    
    var sendThrowsError: Bool
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping @Sendable ((any Error)?) -> Void) {
        if sendThrowsError {
            completionHandler(NSError(domain: "MockURLSessionWebSocketTask.send error", code: 0))
        }
    }

    func send(_ message: URLSessionWebSocketTask.Message) async throws {
        if sendThrowsError {
            throw NSError(domain: "MockURLSessionWebSocketTask.send error", code: 0)
        }
    }

    // MARK: receive()
    
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
