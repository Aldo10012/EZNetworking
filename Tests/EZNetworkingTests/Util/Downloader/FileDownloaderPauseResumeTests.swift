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
        #expect(await sut.state == .paused(resumeData: "resume_data".data(using: .utf8)!))
        try await Task.sleep(for: .milliseconds(10))
        try await sut.resume()
        #expect(await sut.state == .downloading)
        try await Task.sleep(for: .milliseconds(10))
        downloadInterceptor.simulateDownloadProgress(0.6)
        try await Task.sleep(for: .milliseconds(10))
        mockURLSession.resumeDownloadCompletionHandler?(mockFileLocation, mockHTTPResponse(statusCode: 200), nil)

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.3),
            .progress(0.6),
            .completed(mockFileLocation)
        ])
        #expect(await sut.state == .completed)
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
        #expect(await sut.state == .failed)
        try await Task.sleep(for: .milliseconds(10))
        await #expect(throws: NetworkingError.downloadFailed(reason: .notPaused)) {
            try await sut.resume()
        }

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
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
        #expect(await sut.state == .paused(resumeData: "resume_data".data(using: .utf8)!))
        try await Task.sleep(for: .milliseconds(10))
        try await sut.cancel()

        var events: [DownloadEvent] = []
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
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        let mockResumeData = "partial".data(using: .utf8)!
        downloadInterceptor.simulateDownloadProgress(0.5)
        try await Task.sleep(for: .milliseconds(10))
        let error = URLError(.networkConnectionLost, userInfo: [NSURLSessionDownloadTaskResumeData: mockResumeData])
        mockURLSession.downloadCompletionHandler?(nil, nil, error)

        var events: [DownloadEvent] = []
        for await event in stream.prefix(2) {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .failed(.downloadFailed(reason: .failedButResumable(underlying: URLError(.networkConnectionLost))))
        ])
        #expect(await sut.state == .failedButCanResume(resumeData: mockResumeData))
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
        try? await Task.sleep(for: .milliseconds(10))
        mockURLSession.downloadCompletionHandler?(nil, nil, URLError(.networkConnectionLost))

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .failed(.downloadFailed(reason: .urlError(underlying: URLError(.networkConnectionLost))))
        ])
        #expect(await sut.state == .failed)
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
        try await Task.sleep(for: .milliseconds(10))
        let error = URLError(.networkConnectionLost, userInfo: [NSURLSessionDownloadTaskResumeData: mockResumeData])
        mockURLSession.downloadCompletionHandler?(nil, nil, error)
        try await Task.sleep(for: .milliseconds(10))
        #expect(await sut.state == .failedButCanResume(resumeData: mockResumeData))
        try await sut.resume()
        #expect(await sut.state == .downloading)
        try await Task.sleep(for: .milliseconds(10))
        downloadInterceptor.simulateDownloadProgress(0.6)
        try await Task.sleep(for: .milliseconds(10))
        mockURLSession.resumeDownloadCompletionHandler?(mockFileLocation, mockHTTPResponse(statusCode: 200), nil)

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.3),
            .failed(.downloadFailed(reason: .failedButResumable(underlying: URLError(.networkConnectionLost)))),
            .progress(0.6),
            .completed(mockFileLocation)
        ])
        #expect(await sut.state == .completed)
    }

    @Test("test cancel from failedButCanResume state")
    func cancelFromFailedRetryableState() async throws {
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        let mockResumeData = "partial".data(using: .utf8)!
        let error = URLError(.networkConnectionLost, userInfo: [NSURLSessionDownloadTaskResumeData: mockResumeData])
        mockURLSession.downloadCompletionHandler?(nil, nil, error)
        try await Task.sleep(for: .milliseconds(10))
        #expect(await sut.state == .failedButCanResume(resumeData: mockResumeData))
        try await sut.cancel()

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .failed(.downloadFailed(reason: .failedButResumable(underlying: URLError(.networkConnectionLost))))
        ])
        #expect(await sut.state == .cancelled)
    }

    @Test("test resume from non-retryable failed state throws")
    func resumeFromNonRetryableFailedState_throws() async throws {
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        mockURLSession.downloadCompletionHandler?(nil, nil, URLError(.networkConnectionLost))

        // Drain stream to ensure the failure event has been fully processed
        for await _ in stream {}

        #expect(await sut.state == .failed)
        await #expect(throws: NetworkingError.downloadFailed(reason: .notPaused)) {
            try await sut.resume()
        }
    }
}

// MARK: - Helpers

private let mockUrl = URL(string: "https://example.com/file.pdf")!
private let mockFileLocation = URL(fileURLWithPath: "/tmp/test.pdf")

private func mockHTTPResponse(statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(url: mockUrl, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}
