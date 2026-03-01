@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloader - pause/resume")
final class FileDownloaderPauseResumeTests {
    // MARK: - Pause & Resume

    @Test("test resuming paused download if has resumeData")
    func resumingPausedDownloadIfhasResumeData() async throws {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        downloadInterceptor.simulateDownloadProgress(0.3)
        try await Task.sleep(for: .milliseconds(10))
        mockURLSession.mockDownloadTask.mockResumeData = "resume_data".data(using: .utf8)
        try await sut.pause()
        try await Task.sleep(for: .milliseconds(10))
        try await sut.resume()
        try await Task.sleep(for: .milliseconds(10))
        downloadInterceptor.simulateDownloadProgress(0.6)
        downloadInterceptor.simulateDownloadComplete(mockFileLocation)

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .started,
            .progress(0.3),
            .paused,
            .resumed,
            .progress(0.6),
            .completed(mockFileLocation)
        ])
    }

    @Test("test resuming paused download fails if has no resumeData")
    func resumingPausedDownloadFailsIfHasNoResumeData() async throws {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        downloadInterceptor.simulateDownloadProgress(0.3)
        try await Task.sleep(for: .milliseconds(10))
        mockURLSession.mockDownloadTask.mockResumeData = nil
        try await sut.pause()
        try await Task.sleep(for: .milliseconds(10))
        await #expect(throws: NetworkingError.downloadFailed(reason: .notPaused)) {
            try await sut.resume()
        }

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .started,
            .progress(0.3),
            .failed(.downloadFailed(reason: .cannotResume))
        ])
    }

    @Test("test cancelling paused download")
    func cancellingPausedDownload() async throws {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        downloadInterceptor.simulateDownloadProgress(0.3)
        try await Task.sleep(for: .milliseconds(10))
        mockURLSession.mockDownloadTask.mockResumeData = "resume_data".data(using: .utf8)
        try await sut.pause()
        try await Task.sleep(for: .milliseconds(10))
        try await sut.cancel()

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .started,
            .progress(0.3),
            .paused,
            .cancelled
        ])
    }

    // MARK: - Retryable failure

    @Test("test failure with resume data yields failedButCanResume and stream stays open")
    func failureWithResumeData_yieldsFailedRetryable() async throws {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        let mockResumeData = "partial".data(using: .utf8)!
        downloadInterceptor.simulateDownloadProgress(0.5)
        downloadInterceptor.simulateFailure(URLError(.networkConnectionLost), resumeData: mockResumeData)

        var events: [DownloadEvent] = []
        for await event in stream.prefix(3) {
            events.append(event)
        }
        #expect(events == [
            .started,
            .progress(0.5),
            .failedButCanResume(.downloadFailed(reason: .urlError(underlying: URLError(.networkConnectionLost))))
        ])
    }

    @Test("test failure without resume data yields failed and stream finishes")
    func failureWithoutResumeData_yieldsFailed() async {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        downloadInterceptor.simulateDownloadProgress(0.5)
        downloadInterceptor.simulateFailure(URLError(.networkConnectionLost))

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .started,
            .progress(0.5),
            .failed(.downloadFailed(reason: .urlError(underlying: URLError(.networkConnectionLost))))
        ])
    }

    @Test("test resume after retryable failure completes successfully")
    func resumeAfterRetryableFailure_completesSuccessfully() async throws {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        let mockResumeData = "partial".data(using: .utf8)!
        downloadInterceptor.simulateDownloadProgress(0.3)
        downloadInterceptor.simulateFailure(URLError(.networkConnectionLost), resumeData: mockResumeData)
        try await Task.sleep(for: .milliseconds(10))
        try await sut.resume()
        try await Task.sleep(for: .milliseconds(10))
        downloadInterceptor.simulateDownloadProgress(0.6)
        downloadInterceptor.simulateDownloadComplete(mockFileLocation)

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .started,
            .progress(0.3),
            .failedButCanResume(.downloadFailed(reason: .urlError(underlying: URLError(.networkConnectionLost)))),
            .resumed,
            .progress(0.6),
            .completed(mockFileLocation)
        ])
    }

    @Test("test cancel from failedButCanResume state")
    func cancelFromFailedRetryableState() async throws {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        let mockResumeData = "partial".data(using: .utf8)!
        downloadInterceptor.simulateFailure(URLError(.networkConnectionLost), resumeData: mockResumeData)
        try await Task.sleep(for: .milliseconds(10))
        try await sut.cancel()

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .started,
            .failedButCanResume(.downloadFailed(reason: .urlError(underlying: URLError(.networkConnectionLost)))),
            .cancelled
        ])
    }

    @Test("test resume from non-retryable failed state throws")
    func resumeFromNonRetryableFailedState_throws() async throws {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        _ = await sut.downloadFileStream()

        downloadInterceptor.simulateFailure(URLError(.networkConnectionLost))
        try await Task.sleep(for: .milliseconds(10))

        await #expect(throws: NetworkingError.downloadFailed(reason: .notPaused)) {
            try await sut.resume()
        }
    }
}

// MARK: - Helpers

private let mockUrl = URL(string: "https://example.com/file.pdf")!
private let mockFileLocation = URL(fileURLWithPath: "/tmp/test.pdf")
