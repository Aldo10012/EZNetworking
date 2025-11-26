import Foundation

public protocol URLSessionTaskProtocol {

    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask

    func downloadTask(with url: URL, completionHandler: @escaping @Sendable (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask
    
    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask

    func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask

    func webSocketTaskInspectable(with url: URL, protocols: [String]) -> WebSocketTaskProtocol
}

extension URLSession: URLSessionTaskProtocol {
    public func webSocketTaskInspectable(with url: URL, protocols: [String]) -> WebSocketTaskProtocol {
        let task: URLSessionWebSocketTask = self.webSocketTask(with: url, protocols: protocols)
        return task as WebSocketTaskProtocol
    }
}
