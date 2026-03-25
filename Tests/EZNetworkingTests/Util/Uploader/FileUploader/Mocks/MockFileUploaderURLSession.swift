import EZNetworking
import Foundation

class MockFileUploaderURLSession: URLSessionProtocol {
    var mockUploadTask = MockUploadTask()
    var mockResumeUploadTask = MockUploadTask()

    func uploadTaskInspectable(with request: URLRequest, fromFile fileURL: URL) -> URLSessionUploadTaskProtocol {
        mockUploadTask
    }

    func uploadTaskInspectable(withResumeData resumeData: Data) -> URLSessionUploadTaskProtocol {
        mockResumeUploadTask
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

    func downloadTaskInspectable(with url: URL) -> URLSessionDownloadTaskProtocol {
        fatalError("Should not be using in this mock")
    }

    func downloadTaskInspectable(withResumeData resumeData: Data) -> URLSessionDownloadTaskProtocol {
        fatalError("Should not be using in this mock")
    }
}
