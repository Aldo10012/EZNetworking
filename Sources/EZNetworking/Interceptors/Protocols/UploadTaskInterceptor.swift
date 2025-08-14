import Foundation

public protocol UploadTaskInterceptor: AnyObject {
    var progress: (Double) -> Void { get set }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    
    // TODO: add a method to track completion of the upload
}
