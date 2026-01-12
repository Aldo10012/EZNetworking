@testable import EZNetworking
import Foundation
import Testing

@Suite("Test SessionDelegateURLSessionDataDelegate")
final class SessionDelegateURLSessionDataDelegateTest {

    @Test("test SessionDelegate.willCacheResponse")
    func testSessionDelegateWillCacheResponse() async {
        let cacheInterceptor = MockCacheInterceptor()
        let delegate = SessionDelegate()
        delegate.cacheInterceptor = cacheInterceptor

        let result = await delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, willCacheResponse: .init())
        #expect(result != nil)
        #expect(cacheInterceptor.didCallWillCacheResponse)
    }

    @Test("test SessionDelegate.willCacheResponse with no CacheInterceptor injected")
    func testSessionDelegateWillCacheResponseWithNoCacheInterceptorInjected() async {
        let delegate = SessionDelegate()

        let result = await delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, willCacheResponse: .init())
        #expect(result != nil)
    }

    @Test("test SessionDelegate.didReceiveResponse")
    func testSessionDelegateDidReceiveResponse() async {
        let dataTaskInterceptor = MockDataTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.dataTaskInterceptor = dataTaskInterceptor

        _ = await delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didReceive: URLResponse())
        #expect(dataTaskInterceptor.didReceiveResponse)
    }

    @Test("test SessionDelegate.didReceiveResponse with no interceptor")
    func testSessionDelegateDidReceiveResponseWithNoInterceptor() async {
        let delegate = SessionDelegate()

        let disposition = await delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didReceive: URLResponse())
        #expect(disposition == .allow)
    }

    @Test("test SessionDelegate.didReceiveData")
    func testSessionDelegateDidReceiveData() {
        let dataTaskInterceptor = MockDataTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.dataTaskInterceptor = dataTaskInterceptor

        delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didReceive: Data())
        #expect(dataTaskInterceptor.didRecieveData)
    }

    @Test("test SessionDelegate.didBecomeDownloadTask")
    func testSessionDelegateDidBecomeDownloadTask() {
        let dataTaskInterceptor = MockDataTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.dataTaskInterceptor = dataTaskInterceptor

        delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didBecome: URLSessionDownloadTask())
        #expect(dataTaskInterceptor.didBecomeDownloadTask)
    }

    @Test("test SessionDelegate.didBecomeStreamTask")
    func testSessionDelegateDidBecomeStreamTask() {
        let dataTaskInterceptor = MockDataTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.dataTaskInterceptor = dataTaskInterceptor

        delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didBecome: URLSessionStreamTask())
        #expect(dataTaskInterceptor.didBecomeStreamTask)
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
