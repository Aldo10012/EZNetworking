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
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        uploadInterceptor.simulateUploadProgress(0.3)
        try await Task.sleep(for: .milliseconds(10))
        mockURLSession.mockUploadTask.mockResumeData = "resume_data".data(using: .utf8)
        try await sut.pause()
        #expect(await sut.state == .paused(resumeData: "resume_data".data(using: .utf8)!))
        try await Task.sleep(for: .milliseconds(10))
        try await sut.resume()
        #expect(await sut.state == .uploading)
        try await Task.sleep(for: .milliseconds(10))
        uploadInterceptor.simulateUploadProgress(0.6)
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
        #expect(await sut.state == .completed)
    }

    @Test("test resuming paused upload fails if has no resumeData")
    func resumingPausedUploadFailsIfHasNoResumeData() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        uploadInterceptor.simulateUploadProgress(0.3)
        try await Task.sleep(for: .milliseconds(10))
        mockURLSession.mockUploadTask.mockResumeData = nil
        try await sut.pause()
        #expect(await sut.state == .failed)
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
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        uploadInterceptor.simulateUploadProgress(0.3)
        try await Task.sleep(for: .milliseconds(10))
        mockURLSession.mockUploadTask.mockResumeData = "resume_data".data(using: .utf8)
        try await sut.pause()
        #expect(await sut.state == .paused(resumeData: "resume_data".data(using: .utf8)!))
        try await Task.sleep(for: .milliseconds(10))
        try await sut.cancel()

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.3)
        ])
        #expect(await sut.state == .cancelled)
    }

    // MARK: - Retryable failure

    @Test("test failure with resume data yields failed with resumable reason and stream stays open")
    func failureWithResumeData_yieldsFailedRetryable() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        let mockResumeData = "partial".data(using: .utf8)!
        uploadInterceptor.simulateUploadProgress(0.5)
        uploadInterceptor.simulateFailure(URLError(.networkConnectionLost), resumeData: mockResumeData)

        var events: [UploadEvent] = []
        for await event in stream.prefix(2) {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .failed(.uploadFailed(reason: .failedButResumable(underlying: URLError(.networkConnectionLost))))
        ])
        #expect(await sut.state == .failedButCanResume(resumeData: mockResumeData))
    }

    @Test("test failure without resume data yields failed and stream finishes")
    func failureWithoutResumeData_yieldsFailed() async {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        uploadInterceptor.simulateUploadProgress(0.5)
        uploadInterceptor.simulateFailure(URLError(.networkConnectionLost))

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .failed(.uploadFailed(reason: .urlError(underlying: URLError(.networkConnectionLost))))
        ])
        #expect(await sut.state == .failed)
    }

    @Test("test resume after retryable failure completes successfully")
    func resumeAfterRetryableFailure_completesSuccessfully() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        let mockResumeData = "partial".data(using: .utf8)!
        uploadInterceptor.simulateUploadProgress(0.3)
        uploadInterceptor.simulateFailure(URLError(.networkConnectionLost), resumeData: mockResumeData)
        try await Task.sleep(for: .milliseconds(10))
        #expect(await sut.state == .failedButCanResume(resumeData: mockResumeData))
        try await sut.resume()
        #expect(await sut.state == .uploading)
        try await Task.sleep(for: .milliseconds(10))
        uploadInterceptor.simulateUploadProgress(0.6)
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
        #expect(await sut.state == .completed)
    }

    @Test("test cancel from failedButCanResume state")
    func cancelFromFailedRetryableState() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        let mockResumeData = "partial".data(using: .utf8)!
        uploadInterceptor.simulateFailure(URLError(.networkConnectionLost), resumeData: mockResumeData)
        try await Task.sleep(for: .milliseconds(10))
        #expect(await sut.state == .failedButCanResume(resumeData: mockResumeData))
        try await sut.cancel()

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .failed(.uploadFailed(reason: .failedButResumable(underlying: URLError(.networkConnectionLost))))
        ])
        #expect(await sut.state == .cancelled)
    }

    @Test("test resume from non-retryable failed state throws")
    func resumeFromNonRetryableFailedState_throws() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        uploadInterceptor.simulateFailure(URLError(.networkConnectionLost))

        // Drain stream to ensure the failure event has been fully processed
        for await _ in stream {}

        #expect(await sut.state == .failed)
        await #expect(throws: NetworkingError.uploadFailed(reason: .notPaused)) {
            try await sut.resume()
        }
    }
}

// MARK: - Helpers

private let mockUrl = URL(string: "https://example.com/upload")!
private let mockFileURL = URL(fileURLWithPath: "/tmp/test.pdf")
private let mockResponseData = Data("upload response".utf8)
