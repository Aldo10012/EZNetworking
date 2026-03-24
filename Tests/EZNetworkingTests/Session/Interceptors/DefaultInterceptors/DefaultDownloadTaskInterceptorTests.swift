@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DefaultDownloadTaskInterceptor")
final class DefaultDownloadTaskInterceptorTests {
    // MARK: - didWriteData

    @Test("test didWriteData emits onProgress event")
    func didWriteData_emitsProgress() {
        var receivedEvent: DownloadTaskInterceptorEvent?
        let sut = DefaultDownloadTaskInterceptor { event in
            receivedEvent = event
        }
        sut.urlSession(.shared, downloadTask: mockDownloadTask, didWriteData: 10, totalBytesWritten: 50, totalBytesExpectedToWrite: 100)

        if case let .onProgress(progress) = receivedEvent {
            #expect(progress == 0.5)
        } else {
            Issue.record("Expected .onProgress event, got \(String(describing: receivedEvent))")
        }
    }

    @Test("test didWriteData does not emit when totalBytesExpectedToWrite is 0")
    func didWriteData_noEmitWhenZeroExpected() {
        var receivedEvent: DownloadTaskInterceptorEvent?
        let sut = DefaultDownloadTaskInterceptor { event in
            receivedEvent = event
        }
        sut.urlSession(.shared, downloadTask: mockDownloadTask, didWriteData: 10, totalBytesWritten: 50, totalBytesExpectedToWrite: 0)

        #expect(receivedEvent == nil)
    }

    // MARK: - didResumeAtOffset

    @Test("test didResumeAtOffset emits onProgress event")
    func didResumeAtOffset_emitsProgress() {
        var receivedEvent: DownloadTaskInterceptorEvent?
        let sut = DefaultDownloadTaskInterceptor { event in
            receivedEvent = event
        }
        sut.urlSession(.shared, downloadTask: mockDownloadTask, didResumeAtOffset: 50, expectedTotalBytes: 100)

        if case let .onProgress(progress) = receivedEvent {
            #expect(progress == 0.5)
        } else {
            Issue.record("Expected .onProgress event, got \(String(describing: receivedEvent))")
        }
    }

    @Test("test didResumeAtOffset does not emit when expectedTotalBytes is 0")
    func didResumeAtOffset_noEmitWhenZeroExpected() {
        var receivedEvent: DownloadTaskInterceptorEvent?
        let sut = DefaultDownloadTaskInterceptor { event in
            receivedEvent = event
        }
        sut.urlSession(.shared, downloadTask: mockDownloadTask, didResumeAtOffset: 50, expectedTotalBytes: 0)

        #expect(receivedEvent == nil)
    }

    // MARK: - didFinishDownloadingTo

    @Test("test didFinishDownloadingTo emits onProgress 1.0")
    func didFinishDownloadingTo_emitsFullProgress() {
        var receivedEvent: DownloadTaskInterceptorEvent?
        let sut = DefaultDownloadTaskInterceptor { event in
            receivedEvent = event
        }
        sut.urlSession(.shared, downloadTask: mockDownloadTask, didFinishDownloadingTo: mockUrl)

        if case let .onProgress(progress) = receivedEvent {
            #expect(progress == 1.0)
        } else {
            Issue.record("Expected .onProgress(1.0) event, got \(String(describing: receivedEvent))")
        }
    }
}

// MARK: - Mock variables

private let mockUrl = URL(string: "https://example.com")!
private var mockDownloadTask: URLSessionDownloadTask {
    URLSession.shared.downloadTask(with: URLRequest(url: mockUrl))
}
