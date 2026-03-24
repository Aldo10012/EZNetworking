import Foundation

class DefaultUploadTaskInterceptor: UploadTaskInterceptor {
    var onEvent: (UploadTaskInterceptorEvent) -> Void

    init(onEvent: @escaping (UploadTaskInterceptorEvent) -> Void = { _ in }) {
        self.onEvent = onEvent
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard totalBytesExpectedToSend > 0 else {
            return
        }
        let currentProgress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        onEvent(.onProgress(currentProgress))
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        onEvent(.onUploadCompleted(data))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error) {
        var resumeData: Data?
        if #available(iOS 17.0, macOS 14.0, *) {
            resumeData = (error as? URLError)?.uploadTaskResumeData
        }
        onEvent(.onUploadFailed(error, resumeData: resumeData))
    }
}
