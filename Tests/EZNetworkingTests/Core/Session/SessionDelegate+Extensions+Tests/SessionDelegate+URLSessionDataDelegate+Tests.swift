@testable import EZNetworking
import Foundation
import Testing

@Suite("Test SessionDelegateURLSessionDataDelegate")
final class SessionDelegateURLSessionDataDelegateTest {
    @Test("test SessionDelegate.willCacheResponse")
    func sessionDelegateWillCacheResponse() async {
        let cacheInterceptor = MockCacheInterceptor()
        let delegate = SessionDelegate()
        delegate.cacheInterceptor = cacheInterceptor

        let result = await delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, willCacheResponse: .init())
        #expect(result != nil)
        #expect(cacheInterceptor.didCallWillCacheResponse)
    }

    @Test("test SessionDelegate.willCacheResponse with no CacheInterceptor injected")
    func sessionDelegateWillCacheResponseWithNoCacheInterceptorInjected() async {
        let delegate = SessionDelegate()

        let result = await delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, willCacheResponse: .init())
        #expect(result != nil)
    }

    @Test("test SessionDelegate.didReceiveResponse")
    func sessionDelegateDidReceiveResponse() async {
        let dataTaskInterceptor = MockDataTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.dataTaskInterceptor = dataTaskInterceptor

        _ = await delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didReceive: URLResponse())
        #expect(dataTaskInterceptor.didReceiveResponse)
    }

    @Test("test SessionDelegate.didReceiveResponse with no interceptor")
    func sessionDelegateDidReceiveResponseWithNoInterceptor() async {
        let delegate = SessionDelegate()

        let disposition = await delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didReceive: URLResponse())
        #expect(disposition == .allow)
    }

    @Test("test SessionDelegate.didReceiveData")
    func sessionDelegateDidReceiveData() {
        let dataTaskInterceptor = MockDataTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.dataTaskInterceptor = dataTaskInterceptor

        delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didReceive: Data())
        #expect(dataTaskInterceptor.didRecieveData)
    }

    @Test("test SessionDelegate.didBecomeDownloadTask")
    func sessionDelegateDidBecomeDownloadTask() {
        let dataTaskInterceptor = MockDataTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.dataTaskInterceptor = dataTaskInterceptor

        delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didBecome: URLSessionDownloadTask())
        #expect(dataTaskInterceptor.didBecomeDownloadTask)
    }

    @Test("test SessionDelegate.didBecomeStreamTask")
    func sessionDelegateDidBecomeStreamTask() {
        let dataTaskInterceptor = MockDataTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.dataTaskInterceptor = dataTaskInterceptor

        delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didBecome: URLSessionStreamTask())
        #expect(dataTaskInterceptor.didBecomeStreamTask)
    }

    // MARK: upload task forwarding

    @Test("test SessionDelegate.didReceiveData forwards to uploadTaskInterceptor when dataTask is URLSessionUploadTask")
    func sessionDelegateDidReceiveDataForwardsToUploadInterceptorForUploadTask() {
        let uploadInterceptor = SpyUploadTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.uploadTaskInterceptor = uploadInterceptor

        delegate.urlSession(.shared, dataTask: mockUrlSessionUploadTask, didReceive: Data("response".utf8))
        #expect(uploadInterceptor.didReceiveData)
    }

    @Test("test SessionDelegate.didReceiveData does not forward to uploadTaskInterceptor for non-upload data task")
    func sessionDelegateDidReceiveDataNotForwardedToUploadInterceptorForPlainDataTask() {
        let uploadInterceptor = SpyUploadTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.uploadTaskInterceptor = uploadInterceptor

        delegate.urlSession(.shared, dataTask: mockUrlSessionDataTask, didReceive: Data("response".utf8))
        #expect(!uploadInterceptor.didReceiveData)
    }

    @Test("test SessionDelegate.didReceiveData still forwards to dataTaskInterceptor even for upload tasks")
    func sessionDelegateDidReceiveDataStillForwardsToDataInterceptorForUploadTask() {
        let dataTaskInterceptor = MockDataTaskInterceptor()
        let uploadInterceptor = SpyUploadTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.dataTaskInterceptor = dataTaskInterceptor
        delegate.uploadTaskInterceptor = uploadInterceptor

        delegate.urlSession(.shared, dataTask: mockUrlSessionUploadTask, didReceive: Data("response".utf8))
        #expect(dataTaskInterceptor.didRecieveData)
        #expect(uploadInterceptor.didReceiveData)
    }
}

// MARK: spy upload interceptor

private class SpyUploadTaskInterceptor: UploadTaskInterceptor {
    var onEvent: @Sendable (UploadTaskInterceptorEvent) -> Void = { _ in }

    var didReceiveData = false

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {}

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        didReceiveData = true
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {}
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

private var mockUrlSessionUploadTask: URLSessionUploadTask {
    URLSession.shared.uploadTask(with: URLRequest(url: URL(string: "https://www.example.com")!), from: Data())
}
