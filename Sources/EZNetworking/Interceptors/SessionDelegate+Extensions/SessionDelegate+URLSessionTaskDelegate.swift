import Foundation

extension SessionDelegate: URLSessionTaskDelegate {
    // Authentication Challenge Interception
    public func urlSession(_ session: URLSession,
                          task: URLSessionTask,
                          didReceive challenge: URLAuthenticationChallenge,
                          completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let interceptor = authenticationInterceptor {
            interceptor.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    // Redirect Interception
    public func urlSession(_ session: URLSession,
                          task: URLSessionTask,
                          willPerformHTTPRedirection response: HTTPURLResponse,
                          newRequest request: URLRequest,
                          completionHandler: @escaping (URLRequest?) -> Void) {
        if let interceptor = redirectInterceptor {
            interceptor.urlSession(session, task: task, willPerformHTTPRedirection: response, newRequest: request, completionHandler: completionHandler)
        } else {
            completionHandler(request)
        }
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
    
    // Async redirect handling
    public func urlSession(_ session: URLSession,
                          task: URLSessionTask,
                          willPerformHTTPRedirection response: HTTPURLResponse,
                          newRequest request: URLRequest) async -> URLRequest? {
        if let interceptor = redirectInterceptor {
            return await interceptor.urlSession(session, task: task, willPerformHTTPRedirection: response, newRequest: request)
        }
        return request
    }
    
    // Async authentication
    public func urlSession(_ session: URLSession,
                          task: URLSessionTask,
                          didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        if let interceptor = authenticationInterceptor {
            return await interceptor.urlSession(session, task: task, didReceive: challenge)
        }
        return (.performDefaultHandling, nil)
    }
}
