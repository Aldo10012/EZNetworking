import EZNetworking
import Foundation

class MockDownloadTaskInterceptor: DownloadTaskInterceptor {
    var onEvent: (DownloadTaskInterceptorEvent) -> Void = { _ in }
    init() {}

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {}
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {}
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {}

    func simulateDownloadProgress(_ progress: Double) {
        onEvent(.onProgress(progress))
    }
}
