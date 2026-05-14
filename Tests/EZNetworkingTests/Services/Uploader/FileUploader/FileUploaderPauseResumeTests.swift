@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileUploader - pause/resume")
final class FileUploaderPauseResumeTests {
    // MARK: - Pause & Resume

    @Test("test resuming paused upload if has resumeData")
    func resumingPausedUploadIfHasResumeData() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        uploadInterceptor.simulateUploadProgress(0.3)
        try await Task.sleep(for: .milliseconds(10))
        mockURLSession.mockUploadTask.mockResumeData = "resume_data".data(using: .utf8)
        try await sut.pause()
        try await Task.sleep(for: .milliseconds(10))
        try await sut.resume()
        try await Task.sleep(for: .milliseconds(10))
        uploadInterceptor.simulateUploadProgress(0.6)
        try await Task.sleep(for: .milliseconds(10))
        uploadInterceptor.simulateUploadComplete(mockResponseData)

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.3),
            .progress(0.6),
            .completed(mockResponseData)
        ])
    }

    @Test("test resuming paused upload fails if has no resumeData")
    func resumingPausedUploadFailsIfHasNoResumeData() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        uploadInterceptor.simulateUploadProgress(0.3)
        try await Task.sleep(for: .milliseconds(10))
        mockURLSession.mockUploadTask.mockResumeData = nil
        try await sut.pause()
        try await Task.sleep(for: .milliseconds(10))
        await #expect(throws: NetworkingError.uploadFailed(reason: .notPaused)) {
            try await sut.resume()
        }

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.3),
            .failed(.uploadFailed(reason: .cannotResume))
        ])
    }

    @Test("test cancelling paused upload")
    func cancellingPausedUpload() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        uploadInterceptor.simulateUploadProgress(0.3)
        try await Task.sleep(for: .milliseconds(10))
        mockURLSession.mockUploadTask.mockResumeData = "resume_data".data(using: .utf8)
        try await sut.pause()
        try await Task.sleep(for: .milliseconds(10))
        try await sut.cancel()

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.3)
        ])
    }

    // MARK: - Retryable failure

    @Test("test failure with resume data yields failed with resumable reason and stream stays open")
    func failureWithResumeData_yieldsFailedRetryable() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        let mockResumeData = "partial".data(using: .utf8)!
        uploadInterceptor.simulateUploadProgress(0.5)
        try await Task.sleep(for: .milliseconds(10))
        uploadInterceptor.simulateFailure(URLError(.networkConnectionLost), resumeData: mockResumeData)

        var events: [UploadEvent] = []
        for await event in stream.prefix(2) {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .failed(.uploadFailed(reason: .failedButResumable(underlying: URLError(.networkConnectionLost))))
        ])
    }

    @Test("test failure without resume data yields failed and stream finishes")
    func failureWithoutResumeData_yieldsFailed() async {
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

    @Test("test resume after retryable failure completes successfully")
    func resumeAfterRetryableFailure_completesSuccessfully() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        let mockResumeData = "partial".data(using: .utf8)!
        uploadInterceptor.simulateUploadProgress(0.3)
        try await Task.sleep(for: .milliseconds(10))
        uploadInterceptor.simulateFailure(URLError(.networkConnectionLost), resumeData: mockResumeData)
        try await Task.sleep(for: .milliseconds(10))
        try await sut.resume()
        try await Task.sleep(for: .milliseconds(10))
        uploadInterceptor.simulateUploadProgress(0.6)
        try await Task.sleep(for: .milliseconds(10))
        uploadInterceptor.simulateUploadComplete(mockResponseData)

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.3),
            .failed(.uploadFailed(reason: .failedButResumable(underlying: URLError(.networkConnectionLost)))),
            .progress(0.6),
            .completed(mockResponseData)
        ])
    }

    @Test("test cancel from failedButCanResume state")
    func cancelFromFailedRetryableState() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        let mockResumeData = "partial".data(using: .utf8)!
        uploadInterceptor.simulateFailure(URLError(.networkConnectionLost), resumeData: mockResumeData)
        try await Task.sleep(for: .milliseconds(10))
        try await sut.cancel()

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .failed(.uploadFailed(reason: .failedButResumable(underlying: URLError(.networkConnectionLost))))
        ])
    }

    @Test("test resume from non-retryable failed state throws")
    func resumeFromNonRetryableFailedState_throws() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let stream = await sut.upload()

        uploadInterceptor.simulateFailure(URLError(.networkConnectionLost))

        // Drain stream to ensure the failure event has been fully processed
        for await _ in stream {}

        await #expect(throws: NetworkingError.uploadFailed(reason: .notPaused)) {
            try await sut.resume()
        }
    }
}

// MARK: - Helpers

private let mockUrl = URL(string: "https://example.com/upload")!
private let mockRequest = UploadRequest(url: "https://example.com/upload")
private let mockFileURL = URL(fileURLWithPath: "/tmp/upload.bin")
private let mockResponseData = Data("ok".utf8)
