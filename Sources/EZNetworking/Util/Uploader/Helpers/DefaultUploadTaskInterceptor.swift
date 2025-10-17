import Foundation

internal class DefaultUploadTaskInterceptor: UploadTaskInterceptor {
    var progress: (Double) -> Void

    init(progress: @escaping (Double) -> Void = { _ in }) {
        self.progress = progress
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard totalBytesExpectedToSend > 0 else {
            return
        }
        let currentProgress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        progress(currentProgress)
    }
}
