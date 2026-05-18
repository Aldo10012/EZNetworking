@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DataUploader")
final class DataUploaderTests {

    // MARK: - upload() event forwarding

    @Test("upload() invokes fileUploader.upload() once")
    func uploadInvokesFileUploaderUpload() async throws {
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: mockTempFileURL,
            dataSaver: MockDataToTempFileSaver(),
            fileUploader: mockUploader
        )

        let stream = await sut.upload()
        await mockUploader.finishStream()
        for await _ in stream {}

        #expect(await mockUploader.uploadCallCount == 1)
    }

    @Test("upload() forwards progress and completed events from the wrapped uploader")
    func uploadForwardsProgressAndCompletedEvents() async {
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: mockTempFileURL,
            dataSaver: MockDataToTempFileSaver(),
            fileUploader: mockUploader
        )

        let stream = await sut.upload()
        await mockUploader.emit(.progress(0.25))
        await mockUploader.emit(.progress(0.75))
        await mockUploader.emit(.completed(mockResponseData))
        await mockUploader.finishStream()

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }

        #expect(events == [
            .progress(0.25),
            .progress(0.75),
            .completed(mockResponseData)
        ])
    }

    @Test("upload() forwards failed events from the wrapped uploader")
    func uploadForwardsFailedEvent() async {
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: mockTempFileURL,
            dataSaver: MockDataToTempFileSaver(),
            fileUploader: mockUploader
        )

        let stream = await sut.upload()
        await mockUploader.emit(.failed(.uploadFailed(reason: .cannotResume)))
        await mockUploader.finishStream()

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }

        #expect(events == [
            .failed(.uploadFailed(reason: .cannotResume))
        ])
    }

    @Test("upload() finishes the outer stream when the inner stream finishes")
    func uploadFinishesOuterStreamWhenInnerFinishes() async {
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: mockTempFileURL,
            dataSaver: MockDataToTempFileSaver(),
            fileUploader: mockUploader
        )

        let stream = await sut.upload()
        await mockUploader.finishStream()

        var iterationCount = 0
        for await _ in stream {
            iterationCount += 1
        }
        #expect(iterationCount == 0)
    }

    // MARK: - Temp file lifecycle

    @Test("upload() does not clear the temp file after an early-exit failed event")
    func uploadDoesNotClearTempFileOnEarlyExitFailure() async throws {
        let mockSaver = MockDataToTempFileSaver()
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: mockTempFileURL,
            dataSaver: mockSaver,
            fileUploader: mockUploader
        )

        let stream = await sut.upload()
        await mockUploader.emit(.failed(.uploadFailed(reason: .alreadyFinished)))
        await mockUploader.finishStream()
        for await _ in stream {}

        try await Task.sleep(for: .milliseconds(20))

        #expect(mockSaver.clearCount == 0)
    }

    @Test("upload() clears the temp file after upload started and the inner stream finishes")
    func uploadClearsTempFileAfterUploadStarted() async throws {
        let mockSaver = MockDataToTempFileSaver()
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: mockTempFileURL,
            dataSaver: mockSaver,
            fileUploader: mockUploader
        )

        let stream = await sut.upload()
        await mockUploader.emit(.progress(0.5))
        await mockUploader.emit(.failed(.uploadFailed(reason: .cannotResume)))
        await mockUploader.finishStream()
        for await _ in stream {}

        try await Task.sleep(for: .milliseconds(20))

        #expect(mockSaver.clearCount == 1)
        #expect(mockSaver.clearedURLs == [mockTempFileURL])
    }

    @Test("upload() clears the temp file after the inner stream finishes with completed")
    func uploadClearsTempFileAfterStreamFinishes() async throws {
        let mockSaver = MockDataToTempFileSaver()
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: mockTempFileURL,
            dataSaver: mockSaver,
            fileUploader: mockUploader
        )

        let stream = await sut.upload()
        await mockUploader.emit(.completed(mockResponseData))
        await mockUploader.finishStream()
        for await _ in stream {}

        try await Task.sleep(for: .milliseconds(20))

        #expect(mockSaver.clearCount == 1)
        #expect(mockSaver.clearedURLs == [mockTempFileURL])
    }

    @Test("upload() does not clear the temp file while upload is in progress")
    func uploadDoesNotClearTempFileWhileInProgress() async throws {
        let mockSaver = MockDataToTempFileSaver()
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: mockTempFileURL,
            dataSaver: mockSaver,
            fileUploader: mockUploader
        )

        let stream = await sut.upload()
        await mockUploader.emit(.progress(0.5))
        try await Task.sleep(for: .milliseconds(30))

        #expect(mockSaver.clearCount == 0)

        withExtendedLifetime(stream) {}
    }

    @Test("upload() does not call clearTempFile when tempFileURL is nil")
    func uploadDoesNotClearWhenTempURLNil() async {
        let mockSaver = MockDataToTempFileSaver()
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: nil,
            dataSaver: mockSaver,
            fileUploader: mockUploader
        )

        let stream = await sut.upload()
        await mockUploader.finishStream()
        for await _ in stream {}

        #expect(mockSaver.clearCount == 0)
    }

    @Test("upload() swallows errors thrown by clearTempFile")
    func uploadSwallowsClearTempFileErrors() async {
        let mockSaver = MockDataToTempFileSaver()
        mockSaver.setClearError(NSError(domain: "test", code: 1))
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: mockTempFileURL,
            dataSaver: mockSaver,
            fileUploader: mockUploader
        )

        let stream = await sut.upload()
        await mockUploader.emit(.completed(mockResponseData))
        await mockUploader.finishStream()

        var events: [UploadEvent] = []
        for await event in stream {
            events.append(event)
        }

        #expect(events == [.completed(mockResponseData)])
        #expect(mockSaver.clearCount == 1)
    }

    // MARK: - pause()

    @Test("pause() forwards to fileUploader")
    func pauseForwards() async throws {
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: nil,
            dataSaver: MockDataToTempFileSaver(),
            fileUploader: mockUploader
        )

        try await sut.pause()

        #expect(await mockUploader.pauseCallCount == 1)
    }

    @Test("pause() propagates errors from fileUploader")
    func pausePropagatesErrors() async {
        let mockUploader = MockUploadable()
        await mockUploader.setPauseError(NetworkingError.uploadFailed(reason: .notUploading))
        let sut = DataUploader(
            tempFileURL: nil,
            dataSaver: MockDataToTempFileSaver(),
            fileUploader: mockUploader
        )

        await #expect(throws: NetworkingError.uploadFailed(reason: .notUploading)) {
            try await sut.pause()
        }
    }

    // MARK: - resume()

    @Test("resume() forwards to fileUploader")
    func resumeForwards() async throws {
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: nil,
            dataSaver: MockDataToTempFileSaver(),
            fileUploader: mockUploader
        )

        try await sut.resume()

        #expect(await mockUploader.resumeCallCount == 1)
    }

    @Test("resume() propagates errors from fileUploader")
    func resumePropagatesErrors() async {
        let mockUploader = MockUploadable()
        await mockUploader.setResumeError(NetworkingError.uploadFailed(reason: .notPaused))
        let sut = DataUploader(
            tempFileURL: nil,
            dataSaver: MockDataToTempFileSaver(),
            fileUploader: mockUploader
        )

        await #expect(throws: NetworkingError.uploadFailed(reason: .notPaused)) {
            try await sut.resume()
        }
    }

    // MARK: - cancel()

    @Test("cancel() forwards to fileUploader")
    func cancelForwards() async throws {
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: nil,
            dataSaver: MockDataToTempFileSaver(),
            fileUploader: mockUploader
        )

        try await sut.cancel()
        try await Task.sleep(for: .milliseconds(50))

        #expect(await mockUploader.cancelCallCount == 1)
    }

    // MARK: - Consumer cancellation propagation

    @Test("cancelling the stream consumer triggers fileUploader.cancel()")
    func streamConsumerCancellationCancelsInnerUpload() async throws {
        let mockUploader = MockUploadable()
        let sut = DataUploader(
            tempFileURL: mockTempFileURL,
            dataSaver: MockDataToTempFileSaver(),
            fileUploader: mockUploader
        )

        let stream = await sut.upload()

        let consumerTask = Task {
            for await _ in stream {}
        }
        try await Task.sleep(for: .milliseconds(50))
        consumerTask.cancel()
        try await Task.sleep(for: .milliseconds(100))

        #expect(await mockUploader.cancelCallCount == 1)
    }

    // MARK: - Public init integration

    @Test("public init writes the data to a file under the temporary directory")
    func publicInitWritesTempFile() async throws {
        let unique = UUID().uuidString
        let payload = Data("payload-\(unique)".utf8)
        let request = UploadRequest(url: "https://example.com/upload")

        let sut = try DataUploader(data: payload, request: request)

        let tempDir = FileManager.default.temporaryDirectory
        let contents = try FileManager.default.contentsOfDirectory(
            at: tempDir,
            includingPropertiesForKeys: nil
        )
        let matched = contents.first { url in
            (try? Data(contentsOf: url)) == payload
        }

        #expect(matched != nil)

        withExtendedLifetime(sut) {}
        if let matched {
            try? FileManager.default.removeItem(at: matched)
        }
    }
}

// MARK: - DefaultDataToTempFileSaver

@Suite("Test DefaultDataToTempFileSaver")
final class DefaultDataToTempFileSaverTests {
    @Test("saveToTempFile writes data to the temp directory and returns its URL")
    func saveWritesDataToTempDirectory() throws {
        let saver = DefaultDataToTempFileSaver()
        let payload = Data("hello-\(UUID().uuidString)".utf8)

        let url = try saver.saveToTempFile(payload)
        defer { try? FileManager.default.removeItem(at: url) }

        #expect(FileManager.default.fileExists(atPath: url.path))
        #expect(try Data(contentsOf: url) == payload)

        let parentDir = url.deletingLastPathComponent().standardizedFileURL.path
        let tempDir = FileManager.default.temporaryDirectory.standardizedFileURL.path
        #expect(parentDir == tempDir)
    }

    @Test("saveToTempFile produces unique URLs across calls")
    func saveProducesUniqueURLs() throws {
        let saver = DefaultDataToTempFileSaver()
        let url1 = try saver.saveToTempFile(Data("a".utf8))
        let url2 = try saver.saveToTempFile(Data("b".utf8))
        defer {
            try? FileManager.default.removeItem(at: url1)
            try? FileManager.default.removeItem(at: url2)
        }
        #expect(url1 != url2)
    }

    @Test("clearTempFile removes the file at the given URL")
    func clearRemovesFile() throws {
        let saver = DefaultDataToTempFileSaver()
        let url = try saver.saveToTempFile(Data("hi".utf8))

        try saver.clearTempFile(at: url)
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test("clearTempFile throws when the file does not exist")
    func clearThrowsWhenMissing() {
        let saver = DefaultDataToTempFileSaver()
        let url = URL(fileURLWithPath: "/tmp/does-not-exist-\(UUID().uuidString)")

        #expect(throws: (any Error).self) {
            try saver.clearTempFile(at: url)
        }
    }
}

// MARK: - Helpers

private let mockTempFileURL = URL(fileURLWithPath: "/tmp/mock-temp-file")
private let mockResponseData = Data("ok".utf8)
