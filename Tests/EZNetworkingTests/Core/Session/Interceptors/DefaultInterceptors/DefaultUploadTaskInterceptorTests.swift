@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DefaultUploadTaskInterceptor")
final class DefaultUploadTaskInterceptorTests {
    // MARK: - didSendBodyData

    @Test("test didSendBodyData emits onProgress at 0%")
    func didSendBodyData_emitsProgressZero() {
        var receivedEvent: UploadTaskInterceptorEvent?
        let sut = DefaultUploadTaskInterceptor { event in
            receivedEvent = event
        }
        sut.urlSession(.shared, task: mockDataTask, didSendBodyData: 0, totalBytesSent: 0, totalBytesExpectedToSend: 100)

        if case let .onProgress(progress) = receivedEvent {
            #expect(progress == 0)
        } else {
            Issue.record("Expected .onProgress event, got \(String(describing: receivedEvent))")
        }
    }

    @Test("test didSendBodyData emits onProgress at 50%")
    func didSendBodyData_emitsProgressHalf() {
        var receivedEvent: UploadTaskInterceptorEvent?
        let sut = DefaultUploadTaskInterceptor { event in
            receivedEvent = event
        }
        sut.urlSession(.shared, task: mockDataTask, didSendBodyData: 50, totalBytesSent: 50, totalBytesExpectedToSend: 100)

        if case let .onProgress(progress) = receivedEvent {
            #expect(progress == 0.5)
        } else {
            Issue.record("Expected .onProgress event, got \(String(describing: receivedEvent))")
        }
    }

    @Test("test didSendBodyData emits onProgress at 100%")
    func didSendBodyData_emitsProgressFull() {
        var receivedEvent: UploadTaskInterceptorEvent?
        let sut = DefaultUploadTaskInterceptor { event in
            receivedEvent = event
        }
        sut.urlSession(.shared, task: mockDataTask, didSendBodyData: 50, totalBytesSent: 100, totalBytesExpectedToSend: 100)

        if case let .onProgress(progress) = receivedEvent {
            #expect(progress == 1)
        } else {
            Issue.record("Expected .onProgress event, got \(String(describing: receivedEvent))")
        }
    }

    @Test("test didSendBodyData does not emit when totalBytesExpectedToSend is 0")
    func didSendBodyData_noEmitWhenZeroExpected() {
        var receivedEvent: UploadTaskInterceptorEvent?
        let sut = DefaultUploadTaskInterceptor { event in
            receivedEvent = event
        }
        sut.urlSession(.shared, task: mockDataTask, didSendBodyData: 10, totalBytesSent: 50, totalBytesExpectedToSend: 0)

        #expect(receivedEvent == nil)
    }

    // MARK: - didReceive data + didCompleteWithError success

    @Test("test didCompleteWithError(nil) with passing validator emits onUploadCompleted with accumulated bytes")
    func didCompleteWithErrorNil_emitsCompletedWithBufferedData() throws {
        var receivedEvent: UploadTaskInterceptorEvent?
        let sut = DefaultUploadTaskInterceptor(validator: MockResponseValidator(shouldSucceed: true)) { event in
            receivedEvent = event
        }
        let task = MockURLSessionUploadTask(
            mockResponse: HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)
        )
        let chunk1 = Data("hello ".utf8)
        let chunk2 = Data("world".utf8)
        sut.urlSession(.shared, dataTask: task, didReceive: chunk1)
        sut.urlSession(.shared, dataTask: task, didReceive: chunk2)
        sut.urlSession(.shared, task: task, didCompleteWithError: nil)

        if case let .onUploadCompleted(data) = receivedEvent {
            #expect(data == Data("hello world".utf8))
        } else {
            Issue.record("Expected .onUploadCompleted event, got \(String(describing: receivedEvent))")
        }
    }

    @Test("test didCompleteWithError(nil) emits onUploadCompleted with empty data when nothing received")
    func didCompleteWithErrorNil_emitsCompletedWithEmptyDataWhenNoBytes() {
        var receivedEvent: UploadTaskInterceptorEvent?
        let sut = DefaultUploadTaskInterceptor(validator: MockResponseValidator(shouldSucceed: true)) { event in
            receivedEvent = event
        }
        let task = MockURLSessionUploadTask(
            mockResponse: HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)
        )
        sut.urlSession(.shared, task: task, didCompleteWithError: nil)

        if case let .onUploadCompleted(data) = receivedEvent {
            #expect(data == Data())
        } else {
            Issue.record("Expected .onUploadCompleted event, got \(String(describing: receivedEvent))")
        }
    }

    // MARK: - didCompleteWithError validation failure

    @Test("test didCompleteWithError(nil) with failing validator emits onUploadFailed with nil resumeData")
    func didCompleteWithErrorNil_emitsFailedOnBadStatus() throws {
        var receivedEvent: UploadTaskInterceptorEvent?
        let sut = DefaultUploadTaskInterceptor(validator: MockResponseValidator(shouldSucceed: false)) { event in
            receivedEvent = event
        }
        let task = MockURLSessionUploadTask(
            mockResponse: HTTPURLResponse(url: mockUrl, statusCode: 500, httpVersion: nil, headerFields: nil)
        )
        sut.urlSession(.shared, task: task, didCompleteWithError: nil)

        if case let .onUploadFailed(error, resumeData) = receivedEvent {
            let networkingError = try #require(error as? NetworkingError)
            #expect(networkingError == NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 500))))
            #expect(resumeData == nil)
        } else {
            Issue.record("Expected .onUploadFailed event, got \(String(describing: receivedEvent))")
        }
    }

    @Test("test didCompleteWithError(nil) with default validator and nil response emits onUploadFailed")
    func didCompleteWithErrorNil_emitsFailedWhenResponseIsNil() throws {
        var receivedEvent: UploadTaskInterceptorEvent?
        let sut = DefaultUploadTaskInterceptor(validator: DefaultResponseValidator()) { event in
            receivedEvent = event
        }
        let task = MockURLSessionUploadTask(mockResponse: nil)
        sut.urlSession(.shared, task: task, didCompleteWithError: nil)

        if case let .onUploadFailed(error, resumeData) = receivedEvent {
            let networkingError = try #require(error as? NetworkingError)
            #expect(networkingError == NetworkingError.responseValidationFailed(reason: .noURLResponse))
            #expect(resumeData == nil)
        } else {
            Issue.record("Expected .onUploadFailed event, got \(String(describing: receivedEvent))")
        }
    }

    // MARK: - didCompleteWithError(error)

    @Test("test didCompleteWithError(URLError) emits onUploadFailed with nil resumeData")
    func didCompleteWithError_emitsFailedWithNilResumeData() {
        var receivedEvent: UploadTaskInterceptorEvent?
        let sut = DefaultUploadTaskInterceptor { event in
            receivedEvent = event
        }
        let error = URLError(.notConnectedToInternet)
        sut.urlSession(.shared, task: mockDataTask, didCompleteWithError: error)

        if case let .onUploadFailed(receivedError, resumeData) = receivedEvent {
            #expect((receivedError as? URLError)?.code == .notConnectedToInternet)
            #expect(resumeData == nil)
        } else {
            Issue.record("Expected .onUploadFailed event, got \(String(describing: receivedEvent))")
        }
    }

    @Test("test didCompleteWithError emits nil resumeData for non-URLError")
    func didCompleteWithError_nilResumeDataForNonURLError() {
        var receivedEvent: UploadTaskInterceptorEvent?
        let sut = DefaultUploadTaskInterceptor { event in
            receivedEvent = event
        }
        let error = NSError(domain: "TestDomain", code: 42)
        sut.urlSession(.shared, task: mockDataTask, didCompleteWithError: error)

        if case let .onUploadFailed(_, resumeData) = receivedEvent {
            #expect(resumeData == nil)
        } else {
            Issue.record("Expected .onUploadFailed event, got \(String(describing: receivedEvent))")
        }
    }

    // MARK: - receivedData buffer is cleared after completion

    @Test("test receivedData buffer is cleared after didCompleteWithError so a reused interceptor does not leak bytes into the next cycle")
    func didCompleteWithError_clearsReceivedDataBuffer() {
        var receivedEvents: [UploadTaskInterceptorEvent] = []
        let sut = DefaultUploadTaskInterceptor(validator: MockResponseValidator(shouldSucceed: true)) { event in
            receivedEvents.append(event)
        }
        let task = MockURLSessionUploadTask(
            mockResponse: HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)
        )

        // First upload cycle
        sut.urlSession(.shared, dataTask: task, didReceive: Data("first ".utf8))
        sut.urlSession(.shared, dataTask: task, didReceive: Data("cycle".utf8))
        sut.urlSession(.shared, task: task, didCompleteWithError: nil)

        // Second upload cycle on the SAME interceptor instance
        sut.urlSession(.shared, dataTask: task, didReceive: Data("second cycle".utf8))
        sut.urlSession(.shared, task: task, didCompleteWithError: nil)

        let completedPayloads: [Data] = receivedEvents.compactMap { event in
            if case let .onUploadCompleted(data) = event { return data }
            return nil
        }
        #expect(completedPayloads == [
            Data("first cycle".utf8),
            Data("second cycle".utf8)
        ])
    }
}

// MARK: - Mock URLSessionUploadTask

class MockURLSessionUploadTask: URLSessionUploadTask, @unchecked Sendable {
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
private var mockDataTask: URLSessionDataTask { URLSessionDataTask() }
