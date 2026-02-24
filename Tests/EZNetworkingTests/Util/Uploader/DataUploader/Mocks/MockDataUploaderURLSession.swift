import EZNetworking
import Foundation

class MockDataUploaderURLSession: URLSessionProtocol {
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
    var completionHandler: ((Data?, URLResponse?, (any Error)?) -> Void)?

    var sessionDelegate: SessionDelegate?
    var progressToExecute: [UploadProgress] = []

    init(
        data: Data?,
        urlResponse: URLResponse? = nil,
        error: Error? = nil
    ) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
    }

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        if let error {
            throw error
        }
        guard let data, let urlResponse else {
            fatalError("Could not configure return type for MockDataUploaderURLSession.upload()")
        }

        simulateDownloadProgress(for: .init())
        return (data, urlResponse)
    }
}

// MARK: Helpers

extension MockDataUploaderURLSession {
    enum UploadProgress {
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
                    task: task,
                    didSendBodyData: 0,
                    totalBytesSent: percent,
                    totalBytesExpectedToSend: 100
                )

            case .complete:
                // Simulate completion
                sessionDelegate?.urlSession(
                    .shared,
                    task: task,
                    didSendBodyData: 0,
                    totalBytesSent: 100,
                    totalBytesExpectedToSend: 100
                )
            }
        }
    }
}

// MARK: unused methods

extension MockDataUploaderURLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
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

    func downloadTask(with url: URL) -> URLSessionDownloadTaskProtocol {
        fatalError("Should not be using in this mock")
    }

    func downloadTask(withResumeData resumeData: Data) -> URLSessionDownloadTaskProtocol {
        fatalError("Should not be using in this mock")
    }
}
