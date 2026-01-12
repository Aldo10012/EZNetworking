import Combine
import Foundation

/// Default implementation of DownloadTaskInterceptor
internal class DefaultDownloadTaskInterceptor: DownloadTaskInterceptor {
    var progress: (Double) -> Void

    init(progress: @escaping (Double) -> Void = { _ in }) {
        self.progress = progress
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        progress(1.0)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let currentProgress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progress(currentProgress)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        let currentProgress = Double(fileOffset) / Double(expectedTotalBytes)
        progress(currentProgress)
    }
}
