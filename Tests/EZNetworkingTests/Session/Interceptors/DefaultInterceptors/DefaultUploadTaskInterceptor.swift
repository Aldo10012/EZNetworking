@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DefaultUploadTaskInterceptor")
final class DefaultUploadTaskInterceptorTests {
    // MARK: - didSendBodyData

    @Test("test didSendBodyData emits onProgress event")
    func didSendBodyData_emitsProgress() {
        var receivedEvent: UploadTaskInterceptorEvent?
        let sut = DefaultUploadTaskInterceptor { event in
            receivedEvent = event
        }
        sut.urlSession(.shared, task: mockDataTask, didSendBodyData: 10, totalBytesSent: 50, totalBytesExpectedToSend: 100)

        if case let .onProgress(progress) = receivedEvent {
            #expect(progress == 0.5)
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

    @Test("test didSendBodyData emits 0% progress")
    func didSendBodyData_emitsZeroProgress() {
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

    @Test("test didSendBodyData emits 100% progress")
    func didSendBodyData_emitsFullProgress() {
        var receivedEvent: UploadTaskInterceptorEvent?
        let sut = DefaultUploadTaskInterceptor { event in
            receivedEvent = event
        }
        sut.urlSession(.shared, task: mockDataTask, didSendBodyData: 0, totalBytesSent: 100, totalBytesExpectedToSend: 100)

        if case let .onProgress(progress) = receivedEvent {
            #expect(progress == 1)
        } else {
            Issue.record("Expected .onProgress event, got \(String(describing: receivedEvent))")
        }
    }

    // MARK: - didReceive data

    @Test("test didReceive data emits onUploadCompleted when response is valid")
    func didReceiveData_emitsCompleted() {
        var receivedEvent: UploadTaskInterceptorEvent?
        let mockValidator = MockUploadResponseValidator(shouldSucceed: true)
        let sut = DefaultUploadTaskInterceptor(validator: mockValidator) { event in
            receivedEvent = event
        }
        let task = MockURLSessionDataTask(
            mockResponse: HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)
        )
        let responseData = Data("response".utf8)
        sut.urlSession(.shared, dataTask: task, didReceive: responseData)

        if case let .onUploadCompleted(data) = receivedEvent {
            #expect(data == responseData)
        } else {
            Issue.record("Expected .onUploadCompleted event, got \(String(describing: receivedEvent))")
        }
    }

    @Test("test didReceive data emits onUploadFailed when response validation fails due to bad status code")
    func didReceiveData_emitsFailedOnBadStatus() throws {
        var receivedEvent: UploadTaskInterceptorEvent?
        let mockValidator = MockUploadResponseValidator(shouldSucceed: false)
        let sut = DefaultUploadTaskInterceptor(validator: mockValidator) { event in
            receivedEvent = event
        }
        let task = MockURLSessionDataTask(
            mockResponse: HTTPURLResponse(url: mockUrl, statusCode: 500, httpVersion: nil, headerFields: nil)
        )
        sut.urlSession(.shared, dataTask: task, didReceive: Data("error".utf8))

        if case let .onUploadFailed(error, resumeData) = receivedEvent {
            let networkingError = try #require(error as? NetworkingError)
            #expect(networkingError == NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 500))))
            #expect(resumeData == nil)
        } else {
            Issue.record("Expected .onUploadFailed event, got \(String(describing: receivedEvent))")
        }
    }

    @Test("test didReceive data emits onUploadFailed when response is nil")
    func didReceiveData_emitsFailedWhenResponseIsNil() throws {
        var receivedEvent: UploadTaskInterceptorEvent?
        let mockValidator = DefaultResponseValidator()
        let sut = DefaultUploadTaskInterceptor(validator: mockValidator) { event in
            receivedEvent = event
        }
        let task = MockURLSessionDataTask(mockResponse: nil)
        sut.urlSession(.shared, dataTask: task, didReceive: Data("data".utf8))

        if case let .onUploadFailed(error, resumeData) = receivedEvent {
            let networkingError = try #require(error as? NetworkingError)
            #expect(networkingError == NetworkingError.responseValidationFailed(reason: .noURLResponse))
            #expect(resumeData == nil)
        } else {
            Issue.record("Expected .onUploadFailed event, got \(String(describing: receivedEvent))")
        }
    }

    // MARK: - didCompleteWithError

    @Test("test didCompleteWithError emits onUploadFailed with nil resumeData when URLError has no resume data")
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
}

// MARK: - Mock URLSessionDataTask

private class MockURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {
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

private struct MockUploadResponseValidator: ResponseValidator {
    let shouldSucceed: Bool

    func validateStatus(from urlResponse: URLResponse?) throws {
        if !shouldSucceed {
            throw NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: HTTPResponse(statusCode: 500, headers: [:])))
        }
    }
}

// MARK: - Mock variables

private let mockUrl = URL(string: "https://example.com")!
private var mockDataTask: URLSessionDataTask { MockURLSessionDataTask(mockResponse: nil) }
