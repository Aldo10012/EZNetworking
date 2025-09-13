import Foundation
import EZNetworking

class MockURLSession: URLSessionTaskProtocol {
    var url: URL?
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
    var completion: ((Data?, URLResponse?, Error?) -> Void)?
    var sessionDelegate: SessionDelegate? = nil
    
    init(data: Data? = nil, urlResponse: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
        self.url = nil
    }
    
    init(data: Data? = nil, url: URL? = nil, urlResponse: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.url = url
        self.urlResponse = urlResponse
        self.error = error
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.completion = completionHandler
        return MockURLSessionDataTask {
            completionHandler(self.data, self.urlResponse, self.error)
        }
    }
    
    func downloadTask(with url: URL, completionHandler: @escaping @Sendable (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        
        simulateDownloadProgress(for: .init())

        return MockURLSessionDownloadTask {
            completionHandler(URL(fileURLWithPath: "/tmp/test.pdf"), self.urlResponse, self.error)
        }
    }
}

extension MockURLSession {
    private func simulateDownloadProgress(for task: URLSessionDownloadTask) {
        // Simulate 50% progress
        sessionDelegate?.urlSession(
            .shared,
            downloadTask: task,
            didWriteData: 50,
            totalBytesWritten: 50,
            totalBytesExpectedToWrite: 100
        )
        
        sessionDelegate?.urlSession(
            .shared,
            downloadTask: task,
            didFinishDownloadingTo: URL(fileURLWithPath: "/tmp/test.pdf")
        )
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    var didCancel: Bool = false
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
    
    override func cancel() {
        didCancel = true
    }
}

class MockURLSessionDownloadTask: URLSessionDownloadTask {
    private let closure: () -> Void
    var didCancel: Bool = false

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
    
    override func cancel() {
        didCancel = true
    }
}
