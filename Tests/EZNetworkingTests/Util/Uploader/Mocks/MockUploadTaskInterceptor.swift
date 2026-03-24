import EZNetworking
import Foundation

class MockUploadTaskInterceptor: UploadTaskInterceptor {
    var onEvent: (UploadTaskInterceptorEvent) -> Void

    init(onEvent: @escaping (UploadTaskInterceptorEvent) -> Void = { _ in }) {
        self.onEvent = onEvent
    }

    var didCallDidSendBodyData = false
    var didCallDidReceiveData = false
    var didCallDidCompleteWithError = false

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        didCallDidSendBodyData = true
        guard totalBytesExpectedToSend > 0 else { return }
        let currentProgress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        onEvent(.onProgress(currentProgress))
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        didCallDidReceiveData = true
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error) {
        didCallDidCompleteWithError = true
    }
}
