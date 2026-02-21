import Foundation

/// Protocol for intercepting URL metrics collection.
public protocol MetricsInterceptor: AnyObject {
    /// Intercepts metrics after task completion.
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics)
}
