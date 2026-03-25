@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileUploader - Task cancellation")
final class FileUploaderTaskCancellationTests {
    @Test("test pause terminates silently when Task is cancelled during cancelByProducingResumeData await")
    func pauseTerminatesSilentlyWhenTaskCancelledDuringAwait() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        uploadInterceptor.simulateUploadProgress(0.5)
        try await Task.sleep(for: .milliseconds(10))

        // Make cancelByProducingResumeData suspend so we have a window to cancel
        mockURLSession.mockUploadTask.onCancelByProducingResumeData = {
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

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5)
        ])
        #expect(await sut.state == .cancelled)
    }

    @Test("test uploadFileStream when parent task is cancelled returns empty stream")
    func uploadFileStream_parentTaskCancelled() async {
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let eventsTask = Task {
            // Spin until this task is cancelled before calling uploadFileStream
            while !Task.isCancelled {
                await Task.yield()
            }
            let stream = await sut.uploadFileStream()
            var events: [UploadEvent] = []
            for await event in stream {
                events.append(event)
            }
            return events
        }
        eventsTask.cancel()

        let events = await eventsTask.value
        #expect(events == [])
        #expect(!mockURLSession.mockUploadTask.didResume)
    }

    @Test("test cancelling stream consumer cancels upload task")
    func streamConsumerCancellation_cancelsUploadTask() async throws {
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()
        #expect(mockURLSession.mockUploadTask.didResume)

        let consumeTask = Task {
            for await _ in stream {}
        }
        try await Task.sleep(nanoseconds: 50_000_000)
        consumeTask.cancel()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(mockURLSession.mockUploadTask.didCancel)
    }
}

// MARK: - Helpers

private let mockUrl = URL(string: "https://example.com/upload")!
private let mockFileURL = URL(fileURLWithPath: "/tmp/test.pdf")
