import EZNetworking
import Foundation

class FileDownloaderMockDownloadTaskInterceptor: DownloadTaskInterceptor {
    var onEvent: (DownloadTaskInterceptorEvent) -> Void

    init(onEvent: @escaping (DownloadTaskInterceptorEvent) -> Void = { _ in }) {
        self.onEvent = onEvent
    }

    var didCallDidFinishDownloadingTo = false
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        didCallDidFinishDownloadingTo = true
    }

    var didCallDidWriteData = false
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        didCallDidWriteData = true
    }

    var didCallDidResumeAtOffset = false
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        didCallDidResumeAtOffset = true
    }

    var didCallDidCompleteWithError = false
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error) {
        didCallDidCompleteWithError = true
    }
}
