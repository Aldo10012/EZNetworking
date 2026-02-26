import Foundation

public enum DownloadTaskInterceptorEvent {
    case onProgress(Double)
    case onDownloadCompleted(URL)
    case onDownloadFailed(Error, resumeData: Data?)
}

/// Protocol for intercepting download tasks specifically.
public protocol DownloadTaskInterceptor: AnyObject {
    /// Callback for download task events (progress, completion, failure)
    var onEvent: (DownloadTaskInterceptorEvent) -> Void { get set }

    /// Intercepts when a download task finishes downloading to a location.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)

    /// Intercepts progress updates during the download task.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)

    /// Intercepts when a download task is resumed.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64)

    /// Intercepts when a download task completes with an error.
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error)
}
