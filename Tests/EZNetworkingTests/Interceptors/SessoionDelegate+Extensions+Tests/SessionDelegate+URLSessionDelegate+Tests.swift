import Foundation
import Testing
@testable import EZNetworking

@Suite("Test SessionDelegateURLSessionDelegate")
final class SessionDelegateURLSessionDelegateTests {
    @Test("test SessionDelegate DidReceiveChallenge")
    func sessionDelegateDidReceiveChallenge() async {
        let authenticationInterceptor = MockAuthenticationInterceptor()
        let delegate = SessionDelegate()
        delegate.authenticationInterceptor = authenticationInterceptor

        let (disposition, credential) = await delegate.urlSession(.shared, didReceive: URLAuthenticationChallenge())
        #expect(disposition == .performDefaultHandling)
        #expect(credential == nil)
        #expect(authenticationInterceptor.didReceiveChallenge)
    }

    @Test("test SessionDelegate DidReceiveChallenge with no interceptor")
    func sessionDelegateDidReceiveChallengeWithNoInterceptor() async {
        let delegate = SessionDelegate()

        let (disposition, credential) = await delegate.urlSession(.shared, didReceive: URLAuthenticationChallenge())
        #expect(disposition == .performDefaultHandling)
        #expect(credential == nil)
    }

    @Test("test SessionDelegate DidCreateTask")
    func sessionDelegateDidCreateTask() {
        let taskLifecycleInterceptor = MockTaskLifecycleInterceptor()
        let delegate = SessionDelegate()
        delegate.taskLifecycleInterceptor = taskLifecycleInterceptor

        delegate.urlSession(.shared, didCreateTask: mockUrlSessionDataTask)
        #expect(taskLifecycleInterceptor.didCreateTask)
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
