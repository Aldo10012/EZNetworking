import Foundation
import EZNetworking

class MockWebSockerURLSession: URLSessionTaskProtocol {
    var didCallWebSocketTaskInspectable = false

    init() {}
    
    func webSocketTaskInspectable(with: URL, protocols: [String]) -> WebSocketTaskProtocol {
        didCallWebSocketTaskInspectable = true
        
        return MockURLSessionWebSocketTask()
    }
}

extension MockWebSockerURLSession {
    // MARK: unused methods
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        fatalError("Should not be using in this mock")
    }
    func downloadTask(with url: URL, completionHandler: @escaping @Sendable (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        fatalError("Should not be using in this mock")
    }
    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
        fatalError("Should not be using in this mock")
    }
    func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
        fatalError("Should not be using in this mock")
    }
}
