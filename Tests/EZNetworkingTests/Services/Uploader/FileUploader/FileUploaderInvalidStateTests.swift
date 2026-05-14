@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileUploader - invalid state")
final class FileUploaderInvalidStateTests {
    @Test("test upload when already uploading emits alreadyUploading")
    func uploadWhenAlreadyUploadingEmitsAlreadyUploading() async {
        let session = MockSession(urlSession: MockFileUploaderURLSession(), delegate: SessionDelegate())
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        _ = await sut.upload()

        let secondStream = await sut.upload()
        var events: [UploadEvent] = []
        for await event in secondStream {
            events.append(event)
        }

        #expect(events == [
            .failed(.uploadFailed(reason: .alreadyUploading))
        ])
    }

    @Test("test upload after completed emits alreadyFinished")
    func uploadAfterCompletedEmitsAlreadyFinished() async {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let firstStream = await sut.upload()
        uploadInterceptor.simulateUploadComplete(mockResponseData)

        // Drain the first stream to let state reach .completed
        for await _ in firstStream {}

        let secondStream = await sut.upload()
        var events: [UploadEvent] = []
        for await event in secondStream {
            events.append(event)
        }

        #expect(events == [
            .failed(.uploadFailed(reason: .alreadyFinished))
        ])
    }

    @Test("test upload when failedButCanResume emits uploadIncompleteButResumable")
    func uploadWhenFailedButCanResumeEmitsUploadIncompleteButResumable() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        let firstStream = await sut.upload()

        let mockResumeData = "partial".data(using: .utf8)!
        uploadInterceptor.simulateFailure(URLError(.networkConnectionLost), resumeData: mockResumeData)
        try await Task.sleep(for: .milliseconds(10))

        let secondStream = await sut.upload()
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
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        await #expect(throws: NetworkingError.uploadFailed(reason: .notUploading)) {
            try await sut.pause()
        }
    }

    @Test("test calling .resume() when not uploading throws")
    func callingResumeWhenNotUploadingThrows() async {
        let session = MockSession(urlSession: MockFileUploaderURLSession(), delegate: SessionDelegate())
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        await #expect(throws: NetworkingError.uploadFailed(reason: .notPaused)) {
            try await sut.resume()
        }
    }

    @Test("test calling .cancel() when not uploading throws")
    func callingCancelWhenNotUploadingThrows() async {
        let session = MockSession(urlSession: MockFileUploaderURLSession(), delegate: SessionDelegate())
        let sut = FileUploader(fileURL: mockFileURL, request: mockRequest, session: session)

        await #expect(throws: NetworkingError.uploadFailed(reason: .notUploading)) {
            try await sut.cancel()
        }
    }
}

// MARK: - Helpers

private let mockUrl = URL(string: "https://example.com/upload")!
private let mockRequest = UploadRequest(url: "https://example.com/upload")
private let mockFileURL = URL(fileURLWithPath: "/tmp/upload.bin")
private let mockResponseData = Data("ok".utf8)
