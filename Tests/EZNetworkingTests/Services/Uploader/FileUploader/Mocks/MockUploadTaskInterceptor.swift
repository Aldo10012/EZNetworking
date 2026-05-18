import EZNetworking
import Foundation

class MockUploadTaskInterceptor: UploadTaskInterceptor {
    var onEvent: @Sendable (UploadTaskInterceptorEvent) -> Void = { _ in }
    init() {}

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {}
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {}
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {}

    func simulateUploadComplete(_ data: Data) {
        onEvent(.onUploadCompleted(data))
    }

    func simulateUploadProgress(_ progress: Double) {
        onEvent(.onProgress(progress))
    }

    func simulateFailure(_ error: Error, resumeData: Data? = nil) {
        onEvent(.onUploadFailed(error.asSendableError, resumeData: resumeData))
    }
}
