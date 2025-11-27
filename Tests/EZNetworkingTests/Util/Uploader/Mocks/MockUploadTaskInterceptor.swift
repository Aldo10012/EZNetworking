import Foundation
import EZNetworking

class MockUploadTaskInterceptor: UploadTaskInterceptor {
    var progress: (Double) -> Void
    init(progress: @escaping (Double) -> Void) {
        self.progress = progress
    }
    
    var didCallDidSendBodyData = false
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        didCallDidSendBodyData = true
        progress(1)
    }
}
