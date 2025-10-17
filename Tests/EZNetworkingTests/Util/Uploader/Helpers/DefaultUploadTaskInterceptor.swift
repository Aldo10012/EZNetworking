@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DefaultUploadTaskInterceptor")
final class DefaultUploadTaskInterceptorTests {
    
    @Test("test DefaultUploadTaskInterceptor can track 0% progress")
    func test_0_percent_progress_tracking() {
        var trackedProgress: Double = 0
        let sut = DefaultUploadTaskInterceptor { progress in
            trackedProgress = progress
        }
        sut.urlSession(.shared, task: mockDataTask, didSendBodyData: 0, totalBytesSent: 0, totalBytesExpectedToSend: 100)
        #expect(trackedProgress == 0)
    }
    
    @Test("test DefaultUploadTaskInterceptor can track 50% progress")
    func test_50_percent_progress_tracking() {
        var trackedProgress: Double = 0
        let sut = DefaultUploadTaskInterceptor { progress in
            trackedProgress = progress
        }
        sut.urlSession(.shared, task: mockDataTask, didSendBodyData: 0, totalBytesSent: 50, totalBytesExpectedToSend: 100)
        #expect(trackedProgress == 0.5)
    }
    
    @Test("test DefaultUploadTaskInterceptor can track 100% progress")
    func test_100_percent_progress_tracking() {
        var trackedProgress: Double = 0
        let sut = DefaultUploadTaskInterceptor { progress in
            trackedProgress = progress
        }
        sut.urlSession(.shared, task: mockDataTask, didSendBodyData: 0, totalBytesSent: 100, totalBytesExpectedToSend: 100)
        #expect(trackedProgress == 1)
    }
    
    
    private let mockUrl: URL = URL(string: "https://example.com")!
    private var mockDataTask: URLSessionDataTask { URLSessionDataTask() }
}
