import Foundation
import EZNetworking

class MockRequestPerformerURLSession: URLSessionTaskProtocol {
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
    var completion: ((Data?, URLResponse?, Error?) -> Void)?
    var sessionDelegate: SessionDelegate? = nil
    
    init(data: Data? = nil, urlResponse: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.completion = completionHandler
        return MockURLSessionDataTask {
            completionHandler(self.data, self.urlResponse, self.error)
        }
    }
    
    // not used for RequestPerformer unit tests
    func downloadTask(with url: URL, completionHandler: @escaping @Sendable (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        MockURLSessionDownloadTask { completionHandler(nil, nil, nil) }
    }
    
    // not used for RequestPerformer unit tests
    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
        URLSessionUploadTask()
    }
}
