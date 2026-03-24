import Foundation

/// Default implementation of DownloadTaskInterceptor
class DefaultDownloadTaskInterceptor: DownloadTaskInterceptor {
    var onEvent: (DownloadTaskInterceptorEvent) -> Void

    init(onEvent: @escaping (DownloadTaskInterceptorEvent) -> Void = { _ in }) {
        self.onEvent = onEvent
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        onEvent(.onProgress(1.0))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let currentProgress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        onEvent(.onProgress(currentProgress))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        guard expectedTotalBytes > 0 else { return }
        let currentProgress = Double(fileOffset) / Double(expectedTotalBytes)
        onEvent(.onProgress(currentProgress))
    }
}
