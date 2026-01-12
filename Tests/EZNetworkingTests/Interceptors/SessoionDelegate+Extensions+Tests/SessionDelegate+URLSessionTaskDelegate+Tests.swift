import Foundation
import Testing
@testable import EZNetworking

@Suite("Test SessionDelegateURLSessionTaskDelegate")
final class SessionDelegateURLSessionTaskDelegateTests {
    @Test("test SessionDelegate DidReceiveChallenge")
    func sessionDelegateDidReceiveChallenge() async {
        let authenticationInterceptor = MockAuthenticationInterceptor()
        let delegate = SessionDelegate()
        delegate.authenticationInterceptor = authenticationInterceptor

        let (disposition, credential) = await delegate.urlSession(.shared, task: mockURLSessionTask, didReceive: URLAuthenticationChallenge())
        #expect(disposition == .performDefaultHandling)
        #expect(credential == nil)
        #expect(authenticationInterceptor.didReceiveChallengeWithTask)
    }

    @Test("test SessionDelegate DidReceiveChallenge with no interceptor")
    func sessionDelegateDidReceiveChallengeWithNoInterceptor() async {
        let delegate = SessionDelegate()

        let (disposition, credential) = await delegate.urlSession(.shared, task: mockURLSessionTask, didReceive: URLAuthenticationChallenge())
        #expect(disposition == .performDefaultHandling)
        #expect(credential == nil)
    }

    @Test("test SessionDelegate WillPerformHTTPRedirection")
    func sessionDelegateWillPerformHTTPRedirection() async {
        let redirectInterceptor = MockRedirectInterceptor()
        let delegate = SessionDelegate()
        delegate.redirectInterceptor = redirectInterceptor

        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 301, httpVersion: nil, headerFields: nil)!
        let request = URLRequest(url: URL(string: "https://redirected.com")!)

        let newRequest = await delegate.urlSession(.shared, task: mockURLSessionTask, willPerformHTTPRedirection: response, newRequest: request)
        #expect(newRequest == request)
        #expect(redirectInterceptor.didRedirect)
    }

    @Test("test SessionDelegate WillPerformHTTPRedirection with no interceptor")
    func sessionDelegateWillPerformHTTPRedirectionWithNoInterceptor() async {
        let delegate = SessionDelegate()

        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 301, httpVersion: nil, headerFields: nil)!
        let request = URLRequest(url: URL(string: "https://redirected.com")!)

        let newRequest = await delegate.urlSession(.shared, task: mockURLSessionTask, willPerformHTTPRedirection: response, newRequest: request)
        #expect(newRequest == request)
    }

    @Test("test SessionDelegate DidFinishCollectingMetrics")
    func sessionDelegateDidFinishCollectingMetrics() {
        let metricsInterceptor = MockMetricsInterceptor()
        let delegate = SessionDelegate()
        delegate.metricsInterceptor = metricsInterceptor

        delegate.urlSession(.shared, task: mockURLSessionTask, didFinishCollecting: mockURLSessionTaskMetrics)

        #expect(metricsInterceptor.didCollectMetrics)
    }

    @Test("test SessionDelegate DidCompleteWithError")
    func sessionDelegateDidCompleteWithError() {
        let taskLifecycleInterceptor = MockTaskLifecycleInterceptor()
        let delegate = SessionDelegate()
        delegate.taskLifecycleInterceptor = taskLifecycleInterceptor

        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
        delegate.urlSession(.shared, task: mockURLSessionTask, didCompleteWithError: error)

        #expect(taskLifecycleInterceptor.didCompleteWithError)
    }

    @Test("test SessionDelegateT askIsWaitingForConnectivity")
    func sessionDelegateTaskIsWaitingForConnectivity() {
        let taskLifecycleInterceptor = MockTaskLifecycleInterceptor()
        let delegate = SessionDelegate()
        delegate.taskLifecycleInterceptor = taskLifecycleInterceptor

        delegate.urlSession(.shared, taskIsWaitingForConnectivity: mockURLSessionTask)

        #expect(taskLifecycleInterceptor.taskIsWaitingForConnectivity)
    }
}

// MARK: Mock classes

private class MockAuthenticationInterceptor: AuthenticationInterceptor {
    var didReceiveChallengeWithTask = false
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        didReceiveChallengeWithTask = true
        return (.performDefaultHandling, nil)
    }

    var didReceiveChallenge = false
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        didReceiveChallenge = true
        return (.performDefaultHandling, nil)
    }
}

private class MockRedirectInterceptor: RedirectInterceptor {
    var didRedirect = false
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        didRedirect = true
        return request
    }
}

private class MockMetricsInterceptor: MetricsInterceptor {
    var didCollectMetrics = false
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        didCollectMetrics = true
    }
}

private class MockTaskLifecycleInterceptor: TaskLifecycleInterceptor {
    var didCompleteWithError = false
    var taskIsWaitingForConnectivity = false

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        didCompleteWithError = true
    }

    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        taskIsWaitingForConnectivity = true
    }

    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {}
}

// MARK: Mock variable

private var mockURLSessionTask: URLSessionTask {
    URLSessionTask()
}

private var mockURLSessionTaskMetrics: URLSessionTaskMetrics {
    URLSessionTaskMetrics()
}
