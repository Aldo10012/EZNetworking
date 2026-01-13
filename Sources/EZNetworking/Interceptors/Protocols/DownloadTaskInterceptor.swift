import Foundation

/// Protocol for intercepting download tasks specifically.
public protocol DownloadTaskInterceptor: AnyObject {
    /// Track the progress of the download process
    var progress: (Double) -> Void { get set }

    /// Intercepts when a download task finishes downloading to a location.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)

    /// Intercepts progress updates during the download task.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)

    /// Intercepts when a download task is resumed.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64)
}
