import EZNetworking
import Foundation

class MockResumableDownloaderURLSession: URLSessionProtocol, @unchecked Sendable {
    var url: URL?
    var urlResponse: URLResponse?
    var error: Error?
    var sessionDelegate: SessionDelegate?

    var progressToExecute: [DownloadProgress] = []
    var mockDownloadTask: MockURLSessionDownloadTaskProtocol = MockURLSessionDownloadTaskProtocol()
    var didCreateTaskFromResumeData = false

    init(url: URL? = nil, urlResponse: URLResponse? = nil, error: Error? = nil) {
        self.url = url
        self.urlResponse = urlResponse
        self.error = error
    }

    func downloadTask(with request: URLRequest) -> URLSessionDownloadTaskProtocol {
        let task = mockDownloadTask
        simulateDownloadProgress(for: .init())
        return task
    }

    func downloadTask(withResumeData resumeData: Data) -> URLSessionDownloadTaskProtocol {
        didCreateTaskFromResumeData = true
        let task = mockDownloadTask
        simulateDownloadProgress(for: .init())
        return task
    }
}

// MARK: Helpers

extension MockResumableDownloaderURLSession {
    enum DownloadProgress {
        case inProgress(percent: Int64)
        case complete
        case failed(Error)
    }

    private func simulateDownloadProgress(for task: URLSessionDownloadTask) {
        for progressToExecute in progressToExecute {
            switch progressToExecute {
            case let .inProgress(percent):
                sessionDelegate?.urlSession(
                    .shared,
                    downloadTask: task,
                    didWriteData: 0,
                    totalBytesWritten: percent,
                    totalBytesExpectedToWrite: 100
                )

            case .complete:
                sessionDelegate?.urlSession(
                    .shared,
                    downloadTask: task,
                    didFinishDownloadingTo: URL(fileURLWithPath: "/tmp/test.pdf")
                )

            case let .failed(error):
                sessionDelegate?.urlSession(
                    .shared,
                    task: task,
                    didCompleteWithError: error
                )
            }
        }
    }
}

// MARK: unused methods

extension MockResumableDownloaderURLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        fatalError("Should not be using in this mock")
    }

    func download(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (URL, URLResponse) {
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
