import Foundation
import EZNetworking

class MockURLSessionWebSocketTask: WebSocketTaskProtocol {

    init(resumeClosure: @escaping (() -> Void) = {},
         sendThrowsError: Bool = false,
         receiveMessage: String = "",
         receiveThrowsError: Bool = false
    ) {
        self.resumeClosure = resumeClosure
        self.sendThrowsError = sendThrowsError
        self.receiveMessage = receiveMessage
        self.receiveThrowsError = receiveThrowsError
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
            completionHandler(MockURLSessionWebSocketTaskError.failedToSendMessage)
        }
    }

    func send(_ message: URLSessionWebSocketTask.Message) async throws {
        if sendThrowsError {
            throw MockURLSessionWebSocketTaskError.failedToSendMessage
        }
    }

    // MARK: receive()

    var receiveMessage: String
    var receiveThrowsError: Bool
    func receive(completionHandler: @escaping @Sendable (Result<URLSessionWebSocketTask.Message, any Error>) -> Void) {
        if receiveThrowsError {
            completionHandler(.failure(MockURLSessionWebSocketTaskError.failedToReceiveMessage))
        } else {
            completionHandler(.success(.string(receiveMessage)))
        }
    }

    func receive() async throws -> URLSessionWebSocketTask.Message {
        if receiveThrowsError {
            throw MockURLSessionWebSocketTaskError.failedToReceiveMessage
        }
        return .string(receiveMessage)
    }

    // MARK: sendPing

    var shouldFailPing: Bool = false
    var pingFailureCount: Int = 0
    func sendPing(pongReceiveHandler: @escaping @Sendable ((any Error)?) -> Void) {
        if shouldFailPing {
            pingFailureCount += 1
            pongReceiveHandler(MockURLSessionWebSocketTaskError.pingError)
        } else {
            pongReceiveHandler(nil)
        }
    }
}

enum MockURLSessionWebSocketTaskError: Error {
    case pingError
    case failedToSendMessage
    case failedToReceiveMessage
}
