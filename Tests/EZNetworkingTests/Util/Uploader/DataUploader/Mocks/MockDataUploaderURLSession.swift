import Foundation
import EZNetworking

class MockDataUploaderURLSession: URLSessionTaskProtocol {
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
    var completionHandler: ((Data?, URLResponse?, (any Error)?) -> Void)?
    
    var sessionDelegate: SessionDelegate? = nil
    var progressToExecute: [UploadProgress] = []
    
    init(data: Data?,
         urlResponse: URLResponse? = nil,
         error: Error? = nil
    ) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
    }
    
    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
        self.completionHandler = completionHandler

        simulateDownloadProgress(for: .init())

        return MockURLSessionUploadTask {
            completionHandler(self.data, self.urlResponse, self.error)
        }
    }
    
    // MARK: unused methods
    
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        URLSessionDataTask()
    }
    
    func downloadTask(with url: URL, completionHandler: @escaping @Sendable (URL?, URLResponse?, (any Error)?) -> Void) -> URLSessionDownloadTask {
        URLSessionDownloadTask()
    }
}

extension MockDataUploaderURLSession {
    enum UploadProgress {
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
