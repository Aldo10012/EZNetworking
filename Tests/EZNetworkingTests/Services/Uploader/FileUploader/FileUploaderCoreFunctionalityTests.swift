@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileUploader - core functionality")
final class FileUploaderCoreFunctionalityTests {
    // MARK: underlying uploadTask

    @Test("test calling FileUploader.upload() calls uploadTask.resume()")
    func callingUploadCallsUploadTaskResume() async {
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        _ = await sut.upload()
        #expect(mockURLSession.mockUploadTask.didResume)
    }

    @Test("test calling FileUploader.cancel() calls uploadTask.cancel()")
    func callingFileUploaderCancelCallsUploadTaskCancel() async throws {
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        _ = await sut.upload()
        try await sut.cancel()
        #expect(mockURLSession.mockUploadTask.didCancel)
    }

    @Test("test calling FileUploader.pause() calls uploadTask.cancelByProducingResumeData()")
    func callingPauseCallsUploadTaskCancelByProducingResumeData() async throws {
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        _ = await sut.upload()
        try await sut.pause()
        #expect(mockURLSession.mockUploadTask.didCancelWhileProducingResumeData)
    }

    // MARK: Upload success

    @Test("test upload success")
    func uploadSuccess() async {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        uploadInterceptor.simulateUploadComplete(mockResponseData)

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .completed(mockResponseData)
        ])
    }

    @Test("test upload success with progress")
    func uploadSuccessWithProgress() async {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        uploadInterceptor.simulateUploadProgress(0.5)
        try? await Task.sleep(for: .milliseconds(10))
        uploadInterceptor.simulateUploadComplete(mockResponseData)

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .completed(mockResponseData)
        ])
    }

    // MARK: Upload failure

    @Test("test upload failure due to network error before complete")
    func uploadFailedDueToNetworkErrorBeforeCanComplete() async {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        uploadInterceptor.simulateUploadProgress(0.5)
        try? await Task.sleep(for: .milliseconds(10))
        uploadInterceptor.simulateFailure(URLError(.networkConnectionLost))

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .failed(.uploadFailed(reason: .urlError(underlying: URLError(.networkConnectionLost))))
        ])
    }

    @Test("test upload failure due to non 2xx status code before complete")
    func uploadFailedDueToNon2xxStatusCodeBeforeCanComplete() async {
        let delegate = SessionDelegate()
        let session = MockSession(urlSession: MockFileUploaderURLSession(), delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        let delegateTask = makeMockDelegateUploadTask(statusCode: 500)
        delegate.urlSession(.shared, task: delegateTask, didCompleteWithError: nil)

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .failed(.responseValidationFailed(reason: .badHTTPResponse(underlying: HTTPResponse(statusCode: 500))))
        ])
    }

    @Test("test upload failure due to unknown error before complete")
    func uploadFailedDueToUnknownErrorBeforeCanComplete() async {
        enum UnknownError: Error { case error }
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        uploadInterceptor.simulateUploadProgress(0.5)
        try? await Task.sleep(for: .milliseconds(10))
        uploadInterceptor.simulateFailure(UnknownError.error)

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .failed(.uploadFailed(reason: .unknownError(underlying: UnknownError.error)))
        ])
    }

    // MARK: Cancel

    @Test("test cancelling upload mid progress")
    func cancellingUploadMidProgress() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        uploadInterceptor.simulateUploadProgress(0.5)
        try await Task.sleep(for: .milliseconds(10))
        try await sut.cancel()

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5)
        ])
    }

    // MARK: Pause

    @Test("test FileUploader.pause() without resume data terminates with cannotResume")
    func fileUploadPauseWithoutResumeDataTerminatesWithCannotResume() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        uploadInterceptor.simulateUploadProgress(0.5)
        try await Task.sleep(for: .milliseconds(10))
        try await sut.pause()

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .failed(.uploadFailed(reason: .cannotResume))
        ])
    }
}

// MARK: - Helpers

private let mockUrl = URL(string: "https://example.com/upload")!
private let mockRequest = UploadRequest(url: "https://example.com/upload")
private let mockFileURL = URL(fileURLWithPath: "/tmp/upload.bin")
private let mockResponseData = Data("ok".utf8)

private func makeMockDelegateUploadTask(statusCode: Int = 200) -> MockURLSessionUploadTask {
    MockURLSessionUploadTask(
        mockResponse: HTTPURLResponse(url: mockUrl, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    )
}
