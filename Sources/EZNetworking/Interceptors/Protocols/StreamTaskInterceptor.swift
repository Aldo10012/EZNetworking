import Foundation

/// Protocol for intercepting stream tasks specifically
public protocol StreamTaskInterceptor: AnyObject {
    func urlSession(_ session: URLSession, readClosedFor streamTask: URLSessionStreamTask)
    func urlSession(_ session: URLSession, writeClosedFor streamTask: URLSessionStreamTask)
    func urlSession(_ session: URLSession, betterRouteDiscoveredFor streamTask: URLSessionStreamTask)
    func urlSession(_ session: URLSession, streamTask: URLSessionStreamTask, didBecome inputStream: InputStream, outputStream: OutputStream)
}
