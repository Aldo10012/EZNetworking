import EZNetworking
import Foundation

class MockFileDownloaderURLSession: URLSessionProtocol {
    var mockDownloadTask: MockDownloadTask = MockDownloadTask()
    var mockResumeDownloadTask: MockDownloadTask = MockDownloadTask()

    func downloadTask(with url: URL) -> URLSessionDownloadTaskProtocol {
        mockDownloadTask
    }

    func downloadTask(withResumeData resumeData: Data) -> URLSessionDownloadTaskProtocol {
        mockResumeDownloadTask
    }

    // MARK: - Unused methods

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func webSocketTaskInspectable(with request: URLRequest) -> URLSessionWebSocketTaskProtocol {
        fatalError("Should not be using in this mock")
    }

    func bytes(for request: URLRequest) async throws -> (AsyncThrowingStream<UInt8, Error>, URLResponse) {
        fatalError("Should not be using in this mock")
    }
}
