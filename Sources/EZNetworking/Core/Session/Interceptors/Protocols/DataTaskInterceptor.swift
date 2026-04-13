import Foundation

/// Protocol for intercepting data tasks specifically.
public protocol DataTaskInterceptor: AnyObject {
    /// Intercepts data received for a specific data task.
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)

    /// Intercepts when a data task transitions to a download task.
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask)

    /// Intercepts when a data task transitions to a stream task.
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask)

    /// Intercepts the response for a data task before it is processed.
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition
}
