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

    /// Intercepts progress updates during the upload task.
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)

    /// Intercepts when an upload task receives response data.
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)

    /// Intercepts when an upload task completes with an error.
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error)
}
