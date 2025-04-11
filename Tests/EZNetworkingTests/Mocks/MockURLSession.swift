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
    
    init(url: URL? = nil, urlResponse: URLResponse? = nil, error: Error? = nil) {
        self.url = url
        self.urlResponse = urlResponse
        self.error = error
        self.data = nil
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
    
    func dataTask(with url: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.completion = completionHandler
        return MockURLSessionDataTask {
            completionHandler(self.data, self.urlResponse, self.error)
        }
    }
    
    func data(for request: URLRequest, delegate: (URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        
        guard let data, let urlResponse else {
            throw NetworkingError.internalError(.unknown)
        }
        return (data, urlResponse)
    }
    
    func data(from url: URL, delegate: (URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        self.url = url
        
        guard let data, let url = self.url, let urlResponse else {
            throw NetworkingError.internalError(.unknown)
        }
        return (data, urlResponse)
    }
    
    func downloadTask(with url: URL, completionHandler: @escaping @Sendable (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        
        simulateDownloadProgress(for: .init())

        return MockURLSessionDownloadTask {
            completionHandler(URL(fileURLWithPath: "/tmp/test.pdf"), self.urlResponse, self.error)
        }
    }
    
    func download(from url: URL, delegate: (URLSessionTaskDelegate)?) async throws -> (URL, URLResponse) {
        if let error = error {
            throw error
        }
        guard let urlResponse else {
            throw NetworkingError.internalError(.unknown)
        }
        
        simulateDownloadProgress(for: .init())

        return (URL(fileURLWithPath: "/tmp/test.pdf"), urlResponse)
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
        
        // Simulate completion
        sessionDelegate?.urlSession(
            .shared,
            downloadTask: task,
            didWriteData: 50,
            totalBytesWritten: 100,
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
