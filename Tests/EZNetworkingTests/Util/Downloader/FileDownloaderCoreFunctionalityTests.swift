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
        #expect(await sut.state == .downloading)
    }

    @Test("test calling FileDownloader.cancel() calls downloadTask.cancel()")
    func callingFileDownloaderCancelCallsDownloadTaskCancel() async throws {
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        _ = await sut.downloadFileStream()
        try await sut.cancel()
        #expect(mockURLSession.mockDownloadTask.didCancel)
        #expect(await sut.state == .cancelled)
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
        let sut = FileDownloader(url: mockUrl, destination: passthroughDestination, session: session)

        let stream = await sut.downloadFileStream()

        downloadInterceptor.simulateDownloadComplete(mockFileLocation)

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .completed(mockFileLocation)
        ])
        #expect(await sut.state == .completed)
    }

    @Test("test download success with progress")
    func downloadSuccessWithProgress() async {
        let downloadInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate(downloadTaskInterceptor: downloadInterceptor)
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, destination: passthroughDestination, session: session)

        let stream = await sut.downloadFileStream()

        downloadInterceptor.simulateDownloadProgress(0.5)
        downloadInterceptor.simulateDownloadComplete(mockFileLocation)

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .completed(mockFileLocation)
        ])
        #expect(await sut.state == .completed)
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
            .progress(0.5),
            .failed(.downloadFailed(reason: .urlError(underlying: URLError(.networkConnectionLost))))
        ])
        #expect(await sut.state == .failed)
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
            .failed(.responseValidationFailed(reason: .badHTTPResponse(underlying: HTTPResponse(statusCode: 500))))
        ])
        #expect(await sut.state == .failed)
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
            .progress(0.5),
            .failed(.downloadFailed(reason: .unknownError(underlying: UnknownError.error)))
        ])
        #expect(await sut.state == .failed)
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
            .progress(0.5)
        ])
        #expect(await sut.state == .cancelled)
    }

    // MARK: Pause

    @Test("test FileDownloader.pause() without resume data terminates with cannotResume")
    func fileDownloadPauseWithoutResumeDataTerminatesWithCannotResume() async throws {
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
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .failed(.downloadFailed(reason: .cannotResume))
        ])
        #expect(await sut.state == .failed)
    }
}

// MARK: - Helpers

private let mockUrl = URL(string: "https://example.com/file.pdf")!
private let mockFileLocation = URL(fileURLWithPath: "/tmp/test.pdf")
private let passthroughDestination: DownloadDestination = .custom { url in url }

private func makeMockDelegateTask(statusCode: Int = 200) -> MockURLSessionDownloadTask {
    MockURLSessionDownloadTask(
        mockResponse: HTTPURLResponse(url: mockUrl, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    )
}
