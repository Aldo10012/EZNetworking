import Foundation
import EZNetworking

class MockDataUploaderURLSession: URLSessionTaskProtocol {
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
    var completionHandler: ((Data?, URLResponse?, (any Error)?) -> Void)?
    
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
