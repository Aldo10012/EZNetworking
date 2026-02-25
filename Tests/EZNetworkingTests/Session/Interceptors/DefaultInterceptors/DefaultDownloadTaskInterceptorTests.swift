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

    @Test("test didFinishDownloadingTo emits onDownloadCompleted when response is valid")
    func didFinishDownloadingTo_emitsCompleted() {
        var receivedEvent: DownloadTaskInterceptorEvent?
        let mockValidator = MockResponseValidator(shouldSucceed: true)
        let sut = DefaultDownloadTaskInterceptor(validator: mockValidator) { event in
            receivedEvent = event
        }
        let task = MockURLSessionDownloadTask(
            mockResponse: HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)
        )
        sut.urlSession(.shared, downloadTask: task, didFinishDownloadingTo: mockUrl)

        if case .onDownloadCompleted = receivedEvent {
            // pass
        } else {
            Issue.record("Expected .onDownloadCompleted event, got \(String(describing: receivedEvent))")
        }
    }

    @Test("test didFinishDownloadingTo emits onDownloadFailed when response validation fails due to bad status code")
    func didFinishDownloadingTo_emitsFailedOnBadStatus() throws {
        var receivedEvent: DownloadTaskInterceptorEvent?
        let mockValidator = MockResponseValidator(shouldSucceed: false)
        let sut = DefaultDownloadTaskInterceptor(validator: mockValidator) { event in
            receivedEvent = event
        }
        let task = MockURLSessionDownloadTask(
            mockResponse: HTTPURLResponse(url: mockUrl, statusCode: 500, httpVersion: nil, headerFields: nil)
        )
        sut.urlSession(.shared, downloadTask: task, didFinishDownloadingTo: mockUrl)

        if case let .onDownloadFailed(error) = receivedEvent {
            let networkingError = try #require(error as? NetworkingError)
            #expect(networkingError == NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 500))))
        } else {
            Issue.record("Expected .onDownloadFailed event, got \(String(describing: receivedEvent))")
        }
    }

    @Test("test didFinishDownloadingTo emits onDownloadFailed when response validation fails due to no response")
    func didFinishDownloadingTo_emitsFailedWhenResponseIsNil() throws {
        var receivedEvent: DownloadTaskInterceptorEvent?
        let mockValidator = DefaultResponseValidator()
        let sut = DefaultDownloadTaskInterceptor(validator: mockValidator) { event in
            receivedEvent = event
        }
        let task = MockURLSessionDownloadTask(
            mockResponse: nil
        )
        sut.urlSession(.shared, downloadTask: task, didFinishDownloadingTo: mockUrl)

        if case let .onDownloadFailed(error) = receivedEvent {
            let networkingError = try #require(error as? NetworkingError)
            #expect(networkingError == NetworkingError.responseValidationFailed(reason: .noURLResponse))
        } else {
            Issue.record("Expected .onDownloadFailed event, got \(String(describing: receivedEvent))")
        }
    }

    @Test("test didFinishDownloadingTo emits onDownloadFailed when response is nil")
    func didFinishDownloadingTo_emitsFailedOnNilResponse() {
        var receivedEvent: DownloadTaskInterceptorEvent?
        let sut = DefaultDownloadTaskInterceptor { event in
            receivedEvent = event
        }
        let task = MockURLSessionDownloadTask(mockResponse: nil)
        sut.urlSession(.shared, downloadTask: task, didFinishDownloadingTo: mockUrl)

        if case .onDownloadFailed = receivedEvent {
            // pass
        } else {
            Issue.record("Expected .onDownloadFailed event, got \(String(describing: receivedEvent))")
        }
    }

    // MARK: - didCompleteWithError

    @Test("test didCompleteWithError emits onDownloadFailed")
    func didCompleteWithError_emitsFailed() {
        var receivedEvent: DownloadTaskInterceptorEvent?
        let sut = DefaultDownloadTaskInterceptor { event in
            receivedEvent = event
        }
        let error = URLError(.notConnectedToInternet)
        sut.urlSession(.shared, task: mockDownloadTask, didCompleteWithError: error)

        if case let .onDownloadFailed(receivedError) = receivedEvent {
            #expect((receivedError as? URLError)?.code == .notConnectedToInternet)
        } else {
            Issue.record("Expected .onDownloadFailed event, got \(String(describing: receivedEvent))")
        }
    }
}

// MARK: - Mock URLSessionDownloadTask

private class MockURLSessionDownloadTask: URLSessionDownloadTask, @unchecked Sendable {
    private let mockResponse: URLResponse?

    init(mockResponse: URLResponse?) {
        self.mockResponse = mockResponse
        super.init()
    }

    override var response: URLResponse? {
        mockResponse
    }
}

// MARK: - Mock ResponseValidator

private struct MockResponseValidator: ResponseValidator {
    let shouldSucceed: Bool

    func validateStatus(from urlResponse: URLResponse?) throws {
        if !shouldSucceed {
            throw NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: HTTPResponse(statusCode: 500, headers: [:])))
        }
    }
}

// MARK: - Mock variables

private let mockUrl = URL(string: "https://example.com")!
private var mockDownloadTask: URLSessionDownloadTask { MockURLSessionDownloadTask(mockResponse: nil) }
