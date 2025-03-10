import Foundation

/// Protocol for intercepting and handling URL authentication challenges.
public protocol AuthenticationInterceptor: AnyObject {
    /// Intercepts authentication challenges for a specific URLSession task.
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?)

    /// Intercepts authentication challenges for the entire URLSession.
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?)
}
