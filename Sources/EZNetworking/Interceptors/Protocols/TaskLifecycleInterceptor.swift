import Foundation

/// Protocol for intercepting task lifecycle events
public protocol TaskLifecycleInterceptor: AnyObject {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask)
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask)
}
