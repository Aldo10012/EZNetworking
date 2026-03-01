@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloader - Task cancellation")
final class FileDownloaderTaskCancellationTests {
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
