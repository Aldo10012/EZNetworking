import Foundation

// protocol to allow unit testing and mocking for URLSessionWebSocketTask
public protocol WebSocketTaskProtocol {
    func resume()
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    func sendPing(pongReceiveHandler: @escaping @Sendable ((any Error)?) -> Void)
    
    func send(_ message: URLSessionWebSocketTask.Message) async throws
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping @Sendable (Error?) -> Void)
    
    func receive() async throws -> URLSessionWebSocketTask.Message
    func receive(completionHandler: @escaping @Sendable (Result<URLSessionWebSocketTask.Message, Error>) -> Void)
    
    var closeCode: URLSessionWebSocketTask.CloseCode { get }
    var closeReason: Data? { get }
}

extension URLSessionWebSocketTask: WebSocketTaskProtocol {}
