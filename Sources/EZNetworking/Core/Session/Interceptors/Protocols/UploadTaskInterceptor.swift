import Foundation

public enum UploadTaskInterceptorEvent {
    case onProgress(Double)
    case onUploadCompleted(Data)
    case onUploadFailed(Error, resumeData: Data?)
}

/// Protocol for intercepting upload tasks specifically.
public protocol UploadTaskInterceptor: AnyObject {
    /// Callback for upload task events (progress, completion, failure)
    var onEvent: (UploadTaskInterceptorEvent) -> Void { get set }

    /// Intercepts progress updates as the request body is sent.
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)

    /// Intercepts response body bytes as they arrive (the server's reply to the upload).
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)

    /// Intercepts task completion. A nil error signals successful upload; a non-nil error signals failure.
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
}
