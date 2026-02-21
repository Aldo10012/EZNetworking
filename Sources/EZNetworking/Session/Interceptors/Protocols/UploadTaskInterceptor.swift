import Foundation

/// Protocol for intercepting upload tasks specifically.
public protocol UploadTaskInterceptor: AnyObject {
    /// Track the progress of the upload process
    var progress: (Double) -> Void { get set }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
}
