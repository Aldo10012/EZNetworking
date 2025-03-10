import Foundation

/// Protocol for intercepting stream tasks specifically.
public protocol StreamTaskInterceptor: AnyObject {
    /// Intercepts when a stream task's read is closed.
    func urlSession(_ session: URLSession, readClosedFor streamTask: URLSessionStreamTask)

    /// Intercepts when a stream task's write is closed.
    func urlSession(_ session: URLSession, writeClosedFor streamTask: URLSessionStreamTask)

    /// Intercepts when a better route is discovered for a stream task.
    func urlSession(_ session: URLSession, betterRouteDiscoveredFor streamTask: URLSessionStreamTask)

    /// Intercepts when a stream task becomes input and output streams.
    func urlSession(_ session: URLSession, streamTask: URLSessionStreamTask, didBecome inputStream: InputStream, outputStream: OutputStream)
}
