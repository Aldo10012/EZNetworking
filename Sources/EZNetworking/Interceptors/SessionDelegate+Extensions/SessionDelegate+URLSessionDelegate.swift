import Foundation

extension SessionDelegate: URLSessionDelegate {
    public func urlSession(_ session: URLSession,
                          didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        await authenticationInterceptor?.urlSession(session, didReceive: challenge) ?? (.performDefaultHandling, nil)
    }
    
    public func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        taskLifecycleInterceptor?.urlSession(session, didCreateTask: task)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        uploadTaskInterceptor?.urlSession(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }
}
