import Foundation

extension SessionDelegate: URLSessionTaskDelegate {
    // Async authentication
    public func urlSession(_ session: URLSession,
                          task: URLSessionTask,
                          didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        await authenticationInterceptor?.urlSession(session, task: task, didReceive: challenge) ?? (.performDefaultHandling, nil)
    }

    // Redirect Interception
    public func urlSession(_ session: URLSession,
                          task: URLSessionTask,
                          willPerformHTTPRedirection response: HTTPURLResponse,
                          newRequest request: URLRequest) async -> URLRequest? {
        await redirectInterceptor?.urlSession(session, task: task, willPerformHTTPRedirection: response, newRequest: request) ?? request
    }

    // Metrics Interception
    public func urlSession(_ session: URLSession,
                          task: URLSessionTask,
                          didFinishCollecting metrics: URLSessionTaskMetrics) {
        metricsInterceptor?.urlSession(session, task: task, didFinishCollecting: metrics)
    }

    // Task Lifecycle Interception
    public func urlSession(_ session: URLSession,
                          task: URLSessionTask,
                          didCompleteWithError error: Error?) {
        taskLifecycleInterceptor?.urlSession(session, task: task, didCompleteWithError: error)
    }

    public func urlSession(_ session: URLSession,
                          taskIsWaitingForConnectivity task: URLSessionTask) {
        taskLifecycleInterceptor?.urlSession(session, taskIsWaitingForConnectivity: task)
    }

}
