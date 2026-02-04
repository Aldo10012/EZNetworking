import EZNetworking
import Foundation

class MockWebSockerURLSession: URLSessionProtocol {
    private let webSocketTask: MockURLSessionWebSocketTask

    var didCallWebSocketTaskInspectable = false

    init(webSocketTask: MockURLSessionWebSocketTask = MockURLSessionWebSocketTask()) {
        self.webSocketTask = webSocketTask
    }

    func webSocketTaskInspectable(with request: URLRequest) -> URLSessionWebSocketTaskProtocol {
        didCallWebSocketTaskInspectable = true
        return webSocketTask
    }
}

// MARK: unused methods

extension MockWebSockerURLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func download(from url: URL, delegate: (any URLSessionTaskDelegate)?) async throws -> (URL, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
        fatalError("Should not be using in this mock")
    }

    func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
        fatalError("Should not be using in this mock")
    }
}
