@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloader - core functionality")
final class FileDownloaderCoreFunctionalityTests {
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

// MARK: - Helpers

private let mockUrl = URL(string: "https://example.com/file.pdf")!
private let mockFileLocation = URL(fileURLWithPath: "/tmp/test.pdf")

private func makeMockDelegateTask(statusCode: Int = 200) -> MockURLSessionDownloadTask {
    MockURLSessionDownloadTask(
        mockResponse: HTTPURLResponse(url: mockUrl, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    )
}
