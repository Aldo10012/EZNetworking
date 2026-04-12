@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloader - invalid state")
final class FileDownloaderInvalidStateTests {
    @Test("test downloadFileStream when already downloading emits alreadyDownloading")
    func downloadFileStreamWhenAlreadyDownloadingEmitsAlreadyDownloading() async {
        let session = MockSession(urlSession: MockFileDownloaderURLSession(), delegate: SessionDelegate())
        let sut = FileDownloader(request: mockRequest, session: session)

        _ = await sut.downloadFileStream()
        #expect(await sut.state == .downloading)

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
        let sut = FileDownloader(request: mockRequest, session: session)

        let firstStream = await sut.downloadFileStream()
        downloadInterceptor.simulateDownloadComplete(mockFileLocation)

        // Drain the first stream to let state reach .completed
        for await _ in firstStream {}
        #expect(await sut.state == .completed)

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
        let sut = FileDownloader(request: mockRequest, session: session)

        let firstStream = await sut.downloadFileStream()

        let mockResumeData = "partial".data(using: .utf8)!
        downloadInterceptor.simulateFailure(URLError(.networkConnectionLost), resumeData: mockResumeData)
        try await Task.sleep(for: .milliseconds(10))
        #expect(await sut.state == .failedButCanResume(resumeData: mockResumeData))

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
        let sut = FileDownloader(request: mockRequest, session: session)

        #expect(await sut.state == .idle)
        await #expect(throws: NetworkingError.downloadFailed(reason: .notDownloading)) {
            try await sut.pause()
        }
    }

    @Test("test calling .resume() when not downloading throws")
    func callingResumeWhenNotDownloadingThrows() async {
        let session = MockSession(urlSession: MockFileDownloaderURLSession(), delegate: SessionDelegate())
        let sut = FileDownloader(request: mockRequest, session: session)

        #expect(await sut.state == .idle)
        await #expect(throws: NetworkingError.downloadFailed(reason: .notPaused)) {
            try await sut.resume()
        }
    }

    @Test("test calling .cancel() when not downloading throws")
    func callingCancelWhenNotDownloadingThrows() async {
        let session = MockSession(urlSession: MockFileDownloaderURLSession(), delegate: SessionDelegate())
        let sut = FileDownloader(request: mockRequest, session: session)

        #expect(await sut.state == .idle)
        await #expect(throws: NetworkingError.downloadFailed(reason: .notDownloading)) {
            try await sut.cancel()
        }
    }
}

// MARK: - Helpers

private let mockUrl = URL(string: "https://example.com/file.pdf")!
private let mockRequest = URLRequest(url: mockUrl)
private let mockFileLocation = URL(fileURLWithPath: "/tmp/test.pdf")
