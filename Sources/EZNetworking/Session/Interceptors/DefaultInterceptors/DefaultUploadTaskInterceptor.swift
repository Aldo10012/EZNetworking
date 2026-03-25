import Foundation

/// Default implementation of UploadTaskInterceptor
class DefaultUploadTaskInterceptor: UploadTaskInterceptor {
    var onEvent: (UploadTaskInterceptorEvent) -> Void
    private let validator: ResponseValidator

    init(
        validator: ResponseValidator = DefaultResponseValidator(),
        onEvent: @escaping (UploadTaskInterceptorEvent) -> Void = { _ in }
    ) {
        self.validator = validator
        self.onEvent = onEvent
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard totalBytesExpectedToSend > 0 else { return }
        let currentProgress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        onEvent(.onProgress(currentProgress))
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        do {
            try validator.validateStatus(from: dataTask.response)
            onEvent(.onUploadCompleted(data))
        } catch {
            onEvent(.onUploadFailed(error, resumeData: nil))
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error) {
        let resumeData = (error as? URLError)?.uploadTaskResumeData
        onEvent(.onUploadFailed(error, resumeData: resumeData))
    }
}
