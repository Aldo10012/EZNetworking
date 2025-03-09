import XCTest
@testable import EZNetworking

final class SessionDelegateURLSessionDelegateTests: XCTestCase {
    
    func testSessionDelegateDidReceiveChallenge() async {
        let authenticationInterceptor = MockAuthenticationInterceptor()
        let delegate = SessionDelegate()
        delegate.authenticationInterceptor = authenticationInterceptor
        
        let (disposition, credential) = await delegate.urlSession(.shared, didReceive: URLAuthenticationChallenge())
        XCTAssertEqual(disposition, .performDefaultHandling)
        XCTAssertNil(credential)
        XCTAssertTrue(authenticationInterceptor.didReceiveChallenge)
    }
    
    func testSessionDelegateDidReceiveChallengeWithNoInterceptor() async {
        let delegate = SessionDelegate()
        
        let (disposition, credential) = await delegate.urlSession(.shared, didReceive: URLAuthenticationChallenge())
        XCTAssertEqual(disposition, .performDefaultHandling)
        XCTAssertNil(credential)
    }
    
    func testSessionDelegateDidCreateTask() {
        let taskLifecycleInterceptor = MockTaskLifecycleInterceptor()
        let delegate = SessionDelegate()
        delegate.taskLifecycleInterceptor = taskLifecycleInterceptor
        
        delegate.urlSession(.shared, didCreateTask: mockUrlSessionDataTask)
        XCTAssertTrue(taskLifecycleInterceptor.didCreateTask)
    }
}

// MARK: mock classes

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

private class MockTaskLifecycleInterceptor: TaskLifecycleInterceptor {
    var didCompleteWithError = false
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        didCompleteWithError = true
    }
    
    var taskIsWaitingForConnectivity = false
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        taskIsWaitingForConnectivity = true
    }
    
    var didCreateTask = false
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        didCreateTask = true
    }
}

// MARK: mock variables

private var mockUrlSessionDataTask: URLSessionDataTask {
    URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://www.example.com")!))
}
