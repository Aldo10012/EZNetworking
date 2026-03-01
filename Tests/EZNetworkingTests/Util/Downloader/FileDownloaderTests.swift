@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloader")
final class FileDownloaderTests {
    // MARK: underlying downloadTask

    @Test("test calling FileDownloader.downloadFileStream() calls downloadTask.resume()")
    func callingDownloadFaileStreamCallsDownloadTaskResume() async {
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        _ = await sut.downloadFileStream()
        #expect(mockURLSession.mockDownloadTask.didResume)
    }

    @Test("test calling FileDownloader.cancel() calls downloadTask.cancel()")
    func callingFileDownloaderCancelCallsDownloadTaskCancel() async throws {
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        _ = await sut.downloadFileStream()
        try await sut.cancel()
        #expect(mockURLSession.mockDownloadTask.didCancel)
    }

    @Test("test calling FileDownloader.pause() calls downloadTask.cancelWhileProducingResumeData()")
    func callingDownloadFaileStreamCallsDownloadTask() async throws {
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        _ = await sut.downloadFileStream()
        try await sut.pause()
        #expect(mockURLSession.mockDownloadTask.didCancelWhileProducingResumeData)
    }

    // MARK: Download success

    @Test("test download success")
    func downloadSuccess() async {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        downloadInterceptor.simulateDownloadComplete(mockFileLocation)

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .started,
            .completed(mockFileLocation)
        ])
    }

    @Test("test download success with progress")
    func downloadSuccessWithProgress() async {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        downloadInterceptor.simulateDownloadProgress(0.5)
        downloadInterceptor.simulateDownloadComplete(mockFileLocation)

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .started,
            .progress(0.5),
            .completed(mockFileLocation)
        ])
    }

    // MARK: Download failure

    @Test("test download failure due to network error before complete")
    func downladFailedDueToNetworkErrorBeforeCanComplete() async {
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

    @Test("test download failure due to non 2xx status code before complete")
    func downladFailedDueToNon2xxStatusCoderBeforeCanComplete() async {
        let delegate = SessionDelegate()
        let session = MockSession(urlSession: MockFileDownloaderURLSession(), delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        let delegateTask = makeMockDelegateTask(statusCode: 500)
        delegate.urlSession(.shared, downloadTask: delegateTask, didFinishDownloadingTo: mockFileLocation)

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .started,
            .failed(.responseValidationFailed(reason: .badHTTPResponse(underlying: HTTPResponse(statusCode: 500))))
        ])
    }

    @Test("test download failure due to unknown error before complete")
    func downladFailedDueToUnknownErrorBeforeCanComplete() async {
        enum UnknownError: Error { case error }
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        downloadInterceptor.simulateDownloadProgress(0.5)
        downloadInterceptor.simulateFailure(UnknownError.error)

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .started,
            .progress(0.5),
            .failed(.downloadFailed(reason: .unknownError(underlying: UnknownError.error)))
        ])
    }

    // MARK: Cancel

    @Test("test cancelling download mid progress")
    func cancellingDownloadMidProgress() async throws {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        downloadInterceptor.simulateDownloadProgress(0.5)
        try await Task.sleep(for: .milliseconds(10))
        try await sut.cancel()

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .started,
            .progress(0.5),
            .cancelled
        ])
    }

    // MARK: Pause

    @Test("test FileDownloader.pause() successfully pauses download")
    func fileDownloadPauseSuccessfullyPausesDownload() async throws {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        downloadInterceptor.simulateDownloadProgress(0.5)
        try await Task.sleep(for: .milliseconds(10))
        try await sut.pause()

        var events: [DownloadEvent] = []
        for await event in stream.prefix(3) {
            events.append(event)
        }
        #expect(events == [
            .started,
            .progress(0.5),
            .failed(.downloadFailed(reason: .cannotResume))
        ])
    }
}

@Suite("Test FileDownloader - invalid state")
final class FileDownloaderInvalidStateTests {
    @Test("test downloadFileStream when already downloading emits alreadyDownloading")
    func downloadFileStreamWhenAlreadyDownloadingEmitsAlreadyDownloading() async {
        let session = MockSession(urlSession: MockFileDownloaderURLSession(), delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        _ = await sut.downloadFileStream()

        let secondStream = await sut.downloadFileStream()
        var events: [DownloadEvent] = []
        for await event in secondStream {
            events.append(event)
        }

        #expect(events == [
            .failed(.downloadFailed(reason: .alreadyDownloading))
        ])
    }

    @Test("test downloadFileStream after completed emits alreadyFinished")
    func downloadFileStreamAfterCompletedEmitsAlreadyFinished() async {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let firstStream = await sut.downloadFileStream()
        downloadInterceptor.simulateDownloadComplete(mockFileLocation)

        // Drain the first stream to let state reach .completed
        for await _ in firstStream {}

        let secondStream = await sut.downloadFileStream()
        var events: [DownloadEvent] = []
        for await event in secondStream {
            events.append(event)
        }

        #expect(events == [
            .failed(.downloadFailed(reason: .alreadyFinished))
        ])
    }

    @Test("test downloadFileStream when failedButCanResume emits downloadIncompleteButResumable")
    func downloadFileStreamWhenFailedButCanResumeEmitsDownloadIncompleteButResumable() async throws {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let firstStream = await sut.downloadFileStream()

        let mockResumeData = "partial".data(using: .utf8)!
        downloadInterceptor.simulateFailure(URLError(.networkConnectionLost), resumeData: mockResumeData)
        try await Task.sleep(for: .milliseconds(10))

        let secondStream = await sut.downloadFileStream()
        var events: [DownloadEvent] = []
        for await event in secondStream {
            events.append(event)
        }

        #expect(events == [
            .failed(.downloadFailed(reason: .downloadIncompleteButResumable))
        ])

        // Keep firstStream alive so onTermination doesn't trigger cancel()
        withExtendedLifetime(firstStream) {}
    }

    @Test("test calling .pause() when not downloading throws")
    func callingPauseWhenNotDownloadingThrows() async {
        let session = MockSession(urlSession: MockFileDownloaderURLSession(), delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        await #expect(throws: NetworkingError.downloadFailed(reason: .notDownloading)) {
            try await sut.pause()
        }
    }

    @Test("test calling .resume() when not downloading throws")
    func callingResumeWhenNotDownloadingThrows() async {
        let session = MockSession(urlSession: MockFileDownloaderURLSession(), delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        await #expect(throws: NetworkingError.downloadFailed(reason: .notPaused)) {
            try await sut.resume()
        }
    }

    @Test("test calling .cancel() when not downloading throws")
    func callingCancelWhenNotDownloadingThrows() async {
        let session = MockSession(urlSession: MockFileDownloaderURLSession(), delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        await #expect(throws: NetworkingError.downloadFailed(reason: .notDownloading)) {
            try await sut.cancel()
        }
    }
}

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

@Suite("Test FileDownloader - Task cancellation")
final class FileDownloaderTaskCancellationTests {
    // MARK: - Task cancellation

    @Test("test pause yields cancelled when Task is cancelled during cancelByProducingResumeData await")
    func pauseYieldsCancelledWhenTaskCancelledDuringAwait() async throws {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        downloadInterceptor.simulateDownloadProgress(0.5)
        try await Task.sleep(for: .milliseconds(10))

        // Make cancelByProducingResumeData suspend so we have a window to cancel
        mockURLSession.mockDownloadTask.onCancelByProducingResumeData = {
            try? await Task.sleep(for: .seconds(1))
        }

        let pauseTask = Task {
            try await sut.pause()
        }

        // Give pause() time to enter the await
        try await Task.sleep(for: .milliseconds(50))

        // Cancel the task while pause() is suspended in cancelByProducingResumeData
        pauseTask.cancel()
        _ = try? await pauseTask.value

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .started,
            .progress(0.5),
            .cancelled
        ])
    }

    @Test("test downloadFileStream when parent task is cancelled emits cancelled")
    func downloadFileStream_parentTaskCancelled() async {
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        let eventsTask = Task {
            // Spin until this task is cancelled before calling downloadFileStream
            while !Task.isCancelled {
                await Task.yield()
            }
            let stream = await sut.downloadFileStream()
            var events: [DownloadEvent] = []
            for await event in stream {
                events.append(event)
            }
            return events
        }
        eventsTask.cancel()

        let events = await eventsTask.value
        #expect(events == [.cancelled])
        #expect(!mockURLSession.mockDownloadTask.didResume)
    }

    @Test("test cancelling stream consumer cancels download task")
    func streamConsumerCancellation_cancelsDownloadTask() async throws {
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()
        #expect(mockURLSession.mockDownloadTask.didResume)

        let consumeTask = Task {
            for await _ in stream {}
        }
        try await Task.sleep(nanoseconds: 50_000_000)
        consumeTask.cancel()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(mockURLSession.mockDownloadTask.didCancel)
    }
}

// MARK: - Helpers

private let mockUrl = URL(string: "https://example.com/file.pdf")!
private let mockFileLocation = URL(fileURLWithPath: "/tmp/test.pdf")

private func makeMockDelegateTask(statusCode: Int = 200) -> MockURLSessionDownloadTask {
    MockURLSessionDownloadTask(
        mockResponse: HTTPURLResponse(url: mockUrl, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    )
}
