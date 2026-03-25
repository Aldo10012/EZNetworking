@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileUploader - invalid state")
final class FileUploaderInvalidStateTests {
    @Test("test uploadFileStream when already uploading emits alreadyUploading")
    func uploadFileStreamWhenAlreadyUploadingEmitsAlreadyUploading() async {
        let session = MockSession(urlSession: MockFileUploaderURLSession(), delegate: SessionDelegate())
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        _ = await sut.uploadFileStream()
        #expect(await sut.state == .uploading)

        let secondStream = await sut.uploadFileStream()
        var events: [UploadEvent] = []
        for await event in secondStream {
            events.append(event)
        }

        #expect(events == [
            .failed(.uploadFailed(reason: .alreadyUploading))
        ])
    }

    @Test("test uploadFileStream after completed emits alreadyFinished")
    func uploadFileStreamAfterCompletedEmitsAlreadyFinished() async {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let firstStream = await sut.uploadFileStream()
        uploadInterceptor.simulateUploadComplete(mockResponseData)

        // Drain the first stream to let state reach .completed
        for await _ in firstStream {}
        #expect(await sut.state == .completed)

        let secondStream = await sut.uploadFileStream()
        var events: [UploadEvent] = []
        for await event in secondStream {
            events.append(event)
        }

        #expect(events == [
            .failed(.uploadFailed(reason: .alreadyFinished))
        ])
    }

    @Test("test uploadFileStream when failedButCanResume emits uploadIncompleteButResumable")
    func uploadFileStreamWhenFailedButCanResumeEmitsUploadIncompleteButResumable() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let firstStream = await sut.uploadFileStream()

        let mockResumeData = "partial".data(using: .utf8)!
        uploadInterceptor.simulateFailure(URLError(.networkConnectionLost), resumeData: mockResumeData)
        try await Task.sleep(for: .milliseconds(10))
        #expect(await sut.state == .failedButCanResume(resumeData: mockResumeData))

        let secondStream = await sut.uploadFileStream()
        var events: [UploadEvent] = []
        for await event in secondStream {
            events.append(event)
        }

        #expect(events == [
            .failed(.uploadFailed(reason: .uploadIncompleteButResumable))
        ])

        // Keep firstStream alive so onTermination doesn't trigger cancel()
        withExtendedLifetime(firstStream) {}
    }

    @Test("test calling .pause() when not uploading throws")
    func callingPauseWhenNotUploadingThrows() async {
        let session = MockSession(urlSession: MockFileUploaderURLSession(), delegate: SessionDelegate())
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        #expect(await sut.state == .idle)
        await #expect(throws: NetworkingError.uploadFailed(reason: .notUploading)) {
            try await sut.pause()
        }
    }

    @Test("test calling .resume() when not uploading throws")
    func callingResumeWhenNotUploadingThrows() async {
        let session = MockSession(urlSession: MockFileUploaderURLSession(), delegate: SessionDelegate())
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        #expect(await sut.state == .idle)
        await #expect(throws: NetworkingError.uploadFailed(reason: .notPaused)) {
            try await sut.resume()
        }
    }

    @Test("test calling .cancel() when not uploading throws")
    func callingCancelWhenNotUploadingThrows() async {
        let session = MockSession(urlSession: MockFileUploaderURLSession(), delegate: SessionDelegate())
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        #expect(await sut.state == .idle)
        await #expect(throws: NetworkingError.uploadFailed(reason: .notUploading)) {
            try await sut.cancel()
        }
    }
}

// MARK: - Helpers

private let mockUrl = URL(string: "https://example.com/upload")!
private let mockFileURL = URL(fileURLWithPath: "/tmp/test.pdf")
private let mockResponseData = Data("upload response".utf8)
