import EZNetworking
import Foundation

class MockFileDownloaderURLSession: URLSessionProtocol {
    var url: URL?
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
    var completion: ((Data?, URLResponse?, Error?) -> Void)?
    var sessionDelegate: SessionDelegate?

    var progressToExecute: [DownloadProgress] = []

    init(data: Data? = nil, url: URL? = nil, urlResponse: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.url = url
        self.urlResponse = urlResponse
        self.error = error
    }

    func download(from url: URL, delegate: (any URLSessionTaskDelegate)?) async throws -> (URL, URLResponse) {
        if let error {
            throw error
        }
        guard let urlResponse else {
            fatalError("Could not configure return for MockFileDownloaderURLSession.download")
        }
        simulateDownloadProgress(for: .init())
        return (URL(fileURLWithPath: "/tmp/test.pdf"), urlResponse)
    }
}

// MARK: Helpers

extension MockFileDownloaderURLSession {
    enum DownloadProgress {
        case inProgress(percent: Int64)
        case complete
    }

    private func simulateDownloadProgress(for task: URLSessionDownloadTask) {
        for progressToExecute in progressToExecute {
            switch progressToExecute {
            case let .inProgress(percent):
                // Simulate x% progress
                sessionDelegate?.urlSession(
                    .shared,
                    downloadTask: task,
                    didWriteData: 0,
                    totalBytesWritten: percent,
                    totalBytesExpectedToWrite: 100
                )

            case .complete:
                // Simulate completion
                sessionDelegate?.urlSession(
                    .shared,
                    downloadTask: task,
                    didFinishDownloadingTo: URL(fileURLWithPath: "/tmp/test.pdf")
                )
            }
        }
    }
}

// MARK: unused methods

extension MockFileDownloaderURLSession {
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

    func bytes(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (URLSession.AsyncBytes, URLResponse) {
        fatalError("Should not be using in this mock")
    }
}
