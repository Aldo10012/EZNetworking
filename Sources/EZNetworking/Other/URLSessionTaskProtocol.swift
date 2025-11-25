import Foundation

public protocol URLSessionTaskProtocol {

    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask

    func downloadTask(with url: URL, completionHandler: @escaping @Sendable (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask
    
    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask

    func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask

    func webSocketTaskInspectable(with url: URL, protocols: [String]) -> WebSocketTaskProtocol // URLSessionWebSocketTask protocol
}

extension URLSession: URLSessionTaskProtocol {
    public func webSocketTaskInspectable(with url: URL, protocols: [String]) -> WebSocketTaskProtocol {
        let task: URLSessionWebSocketTask = self.webSocketTask(with: url, protocols: protocols)
        return task as WebSocketTaskProtocol
    }
}

// protocol to allow unit testing and mocking for URLSessionWebSocketTask
public protocol WebSocketTaskProtocol {
    func resume()
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    func sendPing(pongReceiveHandler: @escaping @Sendable ((any Error)?) -> Void)
    
    func send(_ message: URLSessionWebSocketTask.Message) async throws
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping @Sendable (Error?) -> Void)
    
    func receive() async throws -> URLSessionWebSocketTask.Message
    func receive(completionHandler: @escaping @Sendable (Result<URLSessionWebSocketTask.Message, Error>) -> Void)
}

extension URLSessionWebSocketTask: WebSocketTaskProtocol {}
