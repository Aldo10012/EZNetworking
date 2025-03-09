import Foundation

/// Protocol for intercepting URL metrics collection
public protocol MetricsInterceptor: AnyObject {
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics)
}
