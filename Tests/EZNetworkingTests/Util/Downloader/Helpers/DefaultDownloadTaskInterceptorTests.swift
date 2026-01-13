import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DefaultDownloadTaskInterceptor")
final class DefaultDownloadTaskInterceptorTests {
    @Test("test .urlSession(_, downloadTask:_, didFinishDownloadingTo:_) tracks progress 100%")
    func didFinishDownloadingTo_tracksProgress_completion() {
        var trackedProgress: Double = 0
        let sut = DefaultDownloadTaskInterceptor { progress in
            trackedProgress = progress
        }
        sut.urlSession(.shared, downloadTask: mockDownloadTask, didFinishDownloadingTo: mockUrl)
        #expect(trackedProgress == 1.0)
    }

    @Test("test .urlSession(_, downloadTask:_, didResumeAtOffset:_, expectedTotalBytes:_) tracks partial progress")
    func didResumeAtOffset_tracksProgress() {
        var trackedProgress: Double = 0
        let sut = DefaultDownloadTaskInterceptor { progress in
            trackedProgress = progress
        }
        sut.urlSession(.shared, downloadTask: mockDownloadTask, didResumeAtOffset: 50, expectedTotalBytes: 100)
        #expect(trackedProgress == 0.5)
    }

    @Test("test .urlSession(_, downloadTask:_, didWriteData:_, totalBytesWritten:_, totalBytesExpectedToWrite:_) tracks partial progress")
    func didWriteData_tracksProgress_() {
        var trackedProgress: Double = 0
        let sut = DefaultDownloadTaskInterceptor { progress in
            trackedProgress = progress
        }
        sut.urlSession(.shared, downloadTask: mockDownloadTask, didWriteData: 10, totalBytesWritten: 50, totalBytesExpectedToWrite: 100)
        #expect(trackedProgress == 0.5)
    }
}

private let mockUrl = URL(string: "https://example.com")!
private var mockDownloadTask: URLSessionDownloadTask { URLSessionDownloadTask() }
