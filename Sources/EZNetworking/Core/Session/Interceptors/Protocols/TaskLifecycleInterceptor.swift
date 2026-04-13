import Foundation

/// Protocol for intercepting task lifecycle events.
public protocol TaskLifecycleInterceptor: AnyObject {
    /// Intercepts when a task completes with or without an error.
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)

    /// Intercepts when a task is waiting for connectivity.
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask)

    /// Intercepts when a task is created.
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask)
}
