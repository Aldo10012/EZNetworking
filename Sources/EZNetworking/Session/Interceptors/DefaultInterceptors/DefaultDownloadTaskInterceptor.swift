import Foundation

/// Default implementation of DownloadTaskInterceptor
class DefaultDownloadTaskInterceptor: DownloadTaskInterceptor {
    var onEvent: (DownloadTaskInterceptorEvent) -> Void
    private let validator: ResponseValidator

    init(
        validator: ResponseValidator = DefaultResponseValidator(),
        onEvent: @escaping (DownloadTaskInterceptorEvent) -> Void = { _ in }
    ) {
        self.validator = validator
        self.onEvent = onEvent
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            try validator.validateStatus(from: downloadTask.response)
            onEvent(.onDownloadCompleted(location))
        } catch {
            onEvent(.onDownloadFailed(error, resumeData: nil))
        }
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

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error) {
        let resumeData = (error as? URLError)?.downloadTaskResumeData
        onEvent(.onDownloadFailed(error, resumeData: resumeData))
    }
}
