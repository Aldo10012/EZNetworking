import Foundation

/// Default implementation of UploadTaskInterceptor
class DefaultUploadTaskInterceptor: UploadTaskInterceptor {
    var onEvent: @Sendable (UploadTaskInterceptorEvent) -> Void
    private let validator: ResponseValidator
    private var receivedData = Data()

    init(
        validator: ResponseValidator = DefaultResponseValidator(),
        onEvent: @Sendable @escaping (UploadTaskInterceptorEvent) -> Void = { _ in }
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
        receivedData.append(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer { receivedData.removeAll(keepingCapacity: false) }
        if let error {
            // URLSession does not surface a public resume-data key in URLError.userInfo for upload tasks
            // the way it does for downloads (`NSURLSessionDownloadTaskResumeData`). Spontaneous-failure
            // resume support for uploads only exists via explicit `cancelByProducingResumeData()`.
            onEvent(.onUploadFailed(error.asSendableError, resumeData: nil))
            return
        }
        do {
            try validator.validateStatus(from: task.response)
            onEvent(.onUploadCompleted(receivedData))
        } catch {
            onEvent(.onUploadFailed(error.asSendableError, resumeData: nil))
        }
    }
}
