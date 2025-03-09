import XCTest
@testable import EZNetworking

final class SessionDelegateURLSessionTaskDelegateTests: XCTestCase {
    
    func testSessionDelegateDidReceiveChallenge() async {
        let authenticationInterceptor = MockAuthenticationInterceptor()
        let delegate = SessionDelegate()
        delegate.authenticationInterceptor = authenticationInterceptor
        
        let (disposition, credential) = await delegate.urlSession(.shared, task: mockURLSessionTask, didReceive: URLAuthenticationChallenge())
        XCTAssertEqual(disposition, .performDefaultHandling)
        XCTAssertNil(credential)
        XCTAssertTrue(authenticationInterceptor.didReceiveChallengeWithTask)
    }
    
    func testSessionDelegateDidReceiveChallengeWithNoInterceptor() async {
        let delegate = SessionDelegate()
        
        let (disposition, credential) = await delegate.urlSession(.shared, task: mockURLSessionTask, didReceive: URLAuthenticationChallenge())
        XCTAssertEqual(disposition, .performDefaultHandling)
        XCTAssertNil(credential)
    }
    
    func testSessionDelegateWillPerformHTTPRedirection() async {
        let redirectInterceptor = MockRedirectInterceptor()
        let delegate = SessionDelegate()
        delegate.redirectInterceptor = redirectInterceptor
        
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 301, httpVersion: nil, headerFields: nil)!
        let request = URLRequest(url: URL(string: "https://redirected.com")!)
        
        let newRequest = await delegate.urlSession(.shared, task: mockURLSessionTask, willPerformHTTPRedirection: response, newRequest: request)
        XCTAssertEqual(newRequest, request)
        XCTAssertTrue(redirectInterceptor.didRedirect)
    }
    
    func testSessionDelegateWillPerformHTTPRedirectionWithNoInterceptor() async {
        let delegate = SessionDelegate()
        
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 301, httpVersion: nil, headerFields: nil)!
        let request = URLRequest(url: URL(string: "https://redirected.com")!)
        
        let newRequest = await delegate.urlSession(.shared, task: mockURLSessionTask, willPerformHTTPRedirection: response, newRequest: request)
        XCTAssertEqual(newRequest, request)
    }
    
    func testSessionDelegateDidFinishCollectingMetrics() {
        let metricsInterceptor = MockMetricsInterceptor()
        let delegate = SessionDelegate()
        delegate.metricsInterceptor = metricsInterceptor
        
        delegate.urlSession(.shared, task: mockURLSessionTask, didFinishCollecting: mockURLSessionTaskMetrics)
        
        XCTAssertTrue(metricsInterceptor.didCollectMetrics)
    }
    
    func testSessionDelegateDidCompleteWithError() {
        let taskLifecycleInterceptor = MockTaskLifecycleInterceptor()
        let delegate = SessionDelegate()
        delegate.taskLifecycleInterceptor = taskLifecycleInterceptor
        
        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
        delegate.urlSession(.shared, task: mockURLSessionTask, didCompleteWithError: error)
        
        XCTAssertTrue(taskLifecycleInterceptor.didCompleteWithError)
    }
    
    func testSessionDelegateTaskIsWaitingForConnectivity() {
        let taskLifecycleInterceptor = MockTaskLifecycleInterceptor()
        let delegate = SessionDelegate()
        delegate.taskLifecycleInterceptor = taskLifecycleInterceptor
        
        delegate.urlSession(.shared, taskIsWaitingForConnectivity: mockURLSessionTask)
        
        XCTAssertTrue(taskLifecycleInterceptor.taskIsWaitingForConnectivity)
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
