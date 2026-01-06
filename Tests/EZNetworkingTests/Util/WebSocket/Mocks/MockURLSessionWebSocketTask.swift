import Foundation
import EZNetworking

class MockURLSessionWebSocketTask: WebSocketTaskProtocol {
    var closeCode: URLSessionWebSocketTask.CloseCode = .goingAway
    var closeReason: Data?

    init(resumeClosure: @escaping (() -> Void) = {},
         sendThrowsError: Bool = false,
         pingThrowsError: Bool = false
    ) {
        self.resumeClosure = resumeClosure
        self.sendThrowsError = sendThrowsError
        self.pingThrowsError = pingThrowsError
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

    func send(_ message: URLSessionWebSocketTask.Message) async throws {
        if sendThrowsError {
            throw MockURLSessionWebSocketTaskError.failedToSendMessage
        }
    }
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping @Sendable ((any Error)?) -> Void) { }

    // MARK: receive()

    func receive() async throws -> URLSessionWebSocketTask.Message {
        return try await withCheckedThrowingContinuation { continuation in
            self.pendingContinuation = continuation
        }
    }
    func receive(completionHandler: @escaping @Sendable (Result<URLSessionWebSocketTask.Message, any Error>) -> Void) { }
    
    private var pendingContinuation: CheckedContinuation<InboundMessage, Error>?
    func simulateReceiveMessage(_ message: InboundMessage) {
        guard let continuation = pendingContinuation else {
            return
        }
        pendingContinuation = nil
        continuation.resume(returning: message)
    }
    func simulateReceiveMessageError() {
        guard let continuation = pendingContinuation else {
            return
        }
        pendingContinuation = nil
        continuation.resume(throwing: MockURLSessionWebSocketTaskError.failedToReceiveMessage)
    }

    // MARK: sendPing

    var pingThrowsError: Bool
    var pingFailureCount: Int = 0
    var didCallSendPing = false
    var pingError: Error?
    
    func sendPing() async throws {
        didCallSendPing = true
        if pingThrowsError {
            pingFailureCount += 1
            let err = MockURLSessionWebSocketTaskError.pingError
            pingError = err
            throw err
        }
    }
    func sendPing(pongReceiveHandler: @escaping @Sendable ((any Error)?) -> Void) { }
}

enum MockURLSessionWebSocketTaskError: Error {
    case pingError
    case failedToSendMessage
    case failedToReceiveMessage
}
