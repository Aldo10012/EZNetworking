import Foundation

/// Protocol for intercepting URL redirect operations
public protocol RedirectInterceptor: AnyObject {    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest?
}
