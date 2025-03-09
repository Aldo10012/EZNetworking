import Foundation

extension SessionDelegate: URLSessionDelegate {
    public func urlSession(_ session: URLSession,
                          didReceive challenge: URLAuthenticationChallenge,
                          completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let interceptor = authenticationInterceptor {
            interceptor.urlSession(session, didReceive: challenge, completionHandler: completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    public func urlSession(_ session: URLSession,
                          didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        if let interceptor = authenticationInterceptor {
            return await interceptor.urlSession(session, didReceive: challenge)
        }
        return (.performDefaultHandling, nil)
    }
    
    public func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        taskLifecycleInterceptor?.urlSession(session, didCreateTask: task)
    }
}
