import XCTest
@testable import EZNetworking

final class SessionDelegateURLSessionDataDelegateTest: XCTestCase {
    
    func testFSessionDelegateWillCacheResponse() async {
        let cacheInterceptor = MockCacheInterceptor()
        let delegate = SessionDelegate()
        delegate.cacheInterceptor = cacheInterceptor
        
        let result = await delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, willCacheResponse: .init())
        XCTAssertNotNil(result)
        XCTAssertTrue(cacheInterceptor.didCallWillCacheResponse)
    }
    
    func testSessionDelegateWillCacheResponseWithNoCacheInterceptorInjected() async {
        let delegate = SessionDelegate()
        
        let result = await delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, willCacheResponse: .init())
        XCTAssertNotNil(result)
    }
    
    func testSessionDelegateDidReceiveResponse() async {
        let dataTaskInterceptor = MockDataTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.dataTaskInterceptor = dataTaskInterceptor
        
        _ = await delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didReceive: URLResponse())
        XCTAssertTrue(dataTaskInterceptor.didReceiveResponse)
    }
    
    func testSessionDelegateDidReceiveResponseWithNoInterceptor() async {
        let delegate = SessionDelegate()
        
        let disposition = await delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didReceive: URLResponse())
        XCTAssertEqual(disposition, .allow)
    }
    
    func testSessionDelegateDidReceiveData() {
        let dataTaskInterceptor = MockDataTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.dataTaskInterceptor = dataTaskInterceptor
        
        delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didReceive: Data())
        XCTAssertTrue(dataTaskInterceptor.didRecieveData)
    }
    
    func testSessionDelegateDidBecomeDownloadTask() {
        let dataTaskInterceptor = MockDataTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.dataTaskInterceptor = dataTaskInterceptor
        
        delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didBecome: URLSessionDownloadTask())
        XCTAssertTrue(dataTaskInterceptor.didBecomeDownloadTask)
    }
    
    func testSessionDelegateDidBecomeStreamTask() {
        let dataTaskInterceptor = MockDataTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.dataTaskInterceptor = dataTaskInterceptor
        
        delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didBecome: URLSessionStreamTask())
        XCTAssertTrue(dataTaskInterceptor.didBecomeStreamTask)
    }
}

// MARK: mocks classes

private class MockCacheInterceptor: CacheInterceptor {
    var didCallWillCacheResponse = false
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse) async -> CachedURLResponse? {
        didCallWillCacheResponse = true
        return proposedResponse
    }
}

private class MockDataTaskInterceptor: DataTaskInterceptor {
    var didRecieveData = false
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        didRecieveData = true
    }
    
    var didBecomeDownloadTask = false
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        didBecomeDownloadTask = true
    }
    
    var didBecomeStreamTask = false
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        didBecomeStreamTask = true
    }
    
    var didReceiveResponse = false
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
        didReceiveResponse = true
        return .allow
    }
}

// MARK: mock variables

private var mockUrlSessionDataTask: URLSessionDataTask {
    URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://www.example.com")!))
}
