@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileUploader - core functionality")
final class FileUploaderCoreFunctionalityTests {
    // MARK: underlying uploadTask

    @Test("test calling FileUploader.uploadFileStream() calls uploadTask.resume()")
    func callingUploadFileStreamCallsUploadTaskResume() async {
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        _ = await sut.uploadFileStream()
        #expect(mockURLSession.mockUploadTask.didResume)
        #expect(await sut.state == .uploading)
    }

    @Test("test calling FileUploader.cancel() calls uploadTask.cancel()")
    func callingFileUploaderCancelCallsUploadTaskCancel() async throws {
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        _ = await sut.uploadFileStream()
        try await sut.cancel()
        #expect(mockURLSession.mockUploadTask.didCancel)
        #expect(await sut.state == .cancelled)
    }

    @Test("test calling FileUploader.pause() calls uploadTask.cancelByProducingResumeData()")
    func callingUploadFileStreamCallsUploadTask() async throws {
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        _ = await sut.uploadFileStream()
        try await sut.pause()
        #expect(mockURLSession.mockUploadTask.didCancelWhileProducingResumeData)
    }

    // MARK: Upload success

    @Test("test upload success")
    func uploadSuccess() async {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        uploadInterceptor.simulateUploadComplete(mockResponseData)

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .completed(mockResponseData)
        ])
        #expect(await sut.state == .completed)
    }

    @Test("test upload success with progress")
    func uploadSuccessWithProgress() async {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        uploadInterceptor.simulateUploadProgress(0.5)
        uploadInterceptor.simulateUploadComplete(mockResponseData)

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .completed(mockResponseData)
        ])
        #expect(await sut.state == .completed)
    }

    // MARK: Upload failure

    @Test("test upload failure due to network error before complete")
    func uploadFailedDueToNetworkErrorBeforeCanComplete() async {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        uploadInterceptor.simulateUploadProgress(0.5)
        uploadInterceptor.simulateFailure(URLError(.networkConnectionLost))

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .failed(.uploadFailed(reason: .urlError(underlying: URLError(.networkConnectionLost))))
        ])
        #expect(await sut.state == .failed)
    }

    @Test("test upload failure due to unknown error before complete")
    func uploadFailedDueToUnknownErrorBeforeCanComplete() async {
        enum UnknownError: Error { case error }
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        uploadInterceptor.simulateUploadProgress(0.5)
        uploadInterceptor.simulateFailure(UnknownError.error)

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .failed(.uploadFailed(reason: .unknownError(underlying: UnknownError.error)))
        ])
        #expect(await sut.state == .failed)
    }

    // MARK: Cancel

    @Test("test cancelling upload mid progress")
    func cancellingUploadMidProgress() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        uploadInterceptor.simulateUploadProgress(0.5)
        try await Task.sleep(for: .milliseconds(10))
        try await sut.cancel()

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5)
        ])
        #expect(await sut.state == .cancelled)
    }

    // MARK: Pause

    @Test("test FileUploader.pause() without resume data terminates with cannotResume")
    func fileUploadPauseWithoutResumeDataTerminatesWithCannotResume() async throws {
        let uploadInterceptor = MockUploadTaskInterceptor()
        let delegate = SessionDelegate(uploadTaskInterceptor: uploadInterceptor)
        let mockURLSession = MockFileUploaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileUploader(url: mockUrl, fileURL: mockFileURL, session: session)

        let stream = await sut.uploadFileStream()

        uploadInterceptor.simulateUploadProgress(0.5)
        try await Task.sleep(for: .milliseconds(10))
        try await sut.pause()

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }
        #expect(events == [
            .progress(0.5),
            .failed(.uploadFailed(reason: .cannotResume))
        ])
        #expect(await sut.state == .failed)
    }
}

// MARK: - Helpers

private let mockUrl = URL(string: "https://example.com/upload")!
private let mockFileURL = URL(fileURLWithPath: "/tmp/test.pdf")
private let mockResponseData = Data("upload response".utf8)
