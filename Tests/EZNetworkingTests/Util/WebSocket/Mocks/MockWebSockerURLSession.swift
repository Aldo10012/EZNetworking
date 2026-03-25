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

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func bytes(for request: URLRequest) async throws -> (AsyncThrowingStream<UInt8, Error>, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func downloadTaskInspectable(with url: URL) -> URLSessionDownloadTaskProtocol {
        fatalError("Should not be using in this mock")
    }

    func downloadTaskInspectable(withResumeData resumeData: Data) -> URLSessionDownloadTaskProtocol {
        fatalError("Should not be using in this mock")
    }
}
