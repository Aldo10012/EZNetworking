import Foundation

public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)

    func download(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (URL, URLResponse)

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse)

    func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse)
    func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask

    func webSocketTaskInspectable(with request: URLRequest) -> URLSessionWebSocketTaskProtocol
}

extension URLSession: URLSessionProtocol {
    public func webSocketTaskInspectable(with request: URLRequest) -> URLSessionWebSocketTaskProtocol {
        let task: URLSessionWebSocketTask = webSocketTask(with: request)
        return task as URLSessionWebSocketTaskProtocol
    }
}
