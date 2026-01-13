import EZNetworking
import Foundation

class MockFileDownloaderURLSession: URLSessionTaskProtocol {
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

    func downloadTask(with url: URL, completionHandler: @escaping @Sendable (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        simulateDownloadProgress(for: .init())

        return MockURLSessionDownloadTask {
            completionHandler(URL(fileURLWithPath: "/tmp/test.pdf"), self.urlResponse, self.error)
        }
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
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        fatalError("Should not be using in this mock")
    }

    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
        fatalError("Should not be using in this mock")
    }

    func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
        fatalError("Should not be using in this mock")
    }

    func webSocketTaskInspectable(with request: URLRequest) -> WebSocketTaskProtocol {
        fatalError("Should not be using in this mock")
    }
}
