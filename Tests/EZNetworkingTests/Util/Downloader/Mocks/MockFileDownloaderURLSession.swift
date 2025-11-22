import Foundation
import EZNetworking

class MockFileDownloaderURLSession: URLSessionTaskProtocol {
    var url: URL?
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
    var completion: ((Data?, URLResponse?, Error?) -> Void)?
    var sessionDelegate: SessionDelegate? = nil
    
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
    
    // MARK: unused methods
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        MockURLSessionDataTask { completionHandler(nil, nil, nil) }
    }
    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
        URLSessionUploadTask()
    }
    func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
        URLSessionUploadTask()
    }
    func webSocketTaskInspectable(with: URL, protocols: [String]) -> WebSocketTaskProtocol {
        MockURLSessionWebSocketTask()
    }
}

extension MockFileDownloaderURLSession {
    enum DownloadProgress {
        case inProgress(percent: Int64)
        case complete
    }

    private func simulateDownloadProgress(for task: URLSessionDownloadTask) {
        
        for progressToExecute in self.progressToExecute {
            switch progressToExecute {
            case .inProgress(let percent):
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

class MockURLSessionWebSocketTask: WebSocketTaskProtocol {
    init() {}

    func resume() {}
    
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {}
    
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping @Sendable ((any Error)?) -> Void) { }
    
    func receive(completionHandler: @escaping @Sendable (Result<URLSessionWebSocketTask.Message, any Error>) -> Void) { }
}
