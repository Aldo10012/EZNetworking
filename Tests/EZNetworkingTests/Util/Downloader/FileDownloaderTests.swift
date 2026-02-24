@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloader")
final class FileDownloaderTests {
    private let mockUrl = URL(string: "https://example.com/file.pdf")!
    private let mockFileLocation = URL(fileURLWithPath: "/tmp/test.pdf")

    private func makeMockDelegateTask(statusCode: Int = 200) -> MockDelegateDownloadTask {
        MockDelegateDownloadTask(
            mockResponse: HTTPURLResponse(url: mockUrl, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        )
    }

    // MARK: - Happy path

    @Test("test downloadFileStream emits started, progress, completed")
    func downloadFileStream_happyPath() async {
        let delegate = SessionDelegate()
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        #expect(mockURLSession.mockDownloadTask.didResume)

        let delegateTask = makeMockDelegateTask()
        delegate.urlSession(.shared, downloadTask: delegateTask, didWriteData: 50, totalBytesWritten: 50, totalBytesExpectedToWrite: 100)
        delegate.urlSession(.shared, downloadTask: delegateTask, didFinishDownloadingTo: mockFileLocation)

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }

        #expect(events.count == 3)
        #expect(events[0] == .started)
        #expect(events[1] == .progress(0.5))
        #expect(events[2] == .completed(mockFileLocation))
    }

    // MARK: - Pause and Resume

    @Test("test pause emits paused event")
    func pause_emitsPaused() async throws {
        let delegate = SessionDelegate()
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)
        mockURLSession.mockDownloadTask.mockResumeData = Data("resume".utf8)

        let stream = await sut.downloadFileStream()

        let eventsTask = Task {
            var events: [DownloadEvent] = []
            for await event in stream {
                events.append(event)
            }
            return events
        }

        try await Task.sleep(nanoseconds: 50_000_000)
        try await sut.pause()
        try await Task.sleep(nanoseconds: 50_000_000)

        // Resume to continue the download
        let delegateTask = makeMockDelegateTask()
        try await sut.resume()
        #expect(mockURLSession.mockResumeDownloadTask.didResume)

        try await Task.sleep(nanoseconds: 50_000_000)
        delegate.urlSession(.shared, downloadTask: delegateTask, didFinishDownloadingTo: mockFileLocation)

        let events = await eventsTask.value

        #expect(events.contains(.started))
        #expect(events.contains(.paused))
        #expect(events.contains(.resumed))
        #expect(events.contains(.completed(mockFileLocation)))
    }

    // MARK: - Cancel

    @Test("test cancel emits cancelled event")
    func cancel_emitsCancelled() async throws {
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        let eventsTask = Task {
            var events: [DownloadEvent] = []
            for await event in stream {
                events.append(event)
            }
            return events
        }

        try await Task.sleep(nanoseconds: 50_000_000)
        try await sut.cancel()

        #expect(mockURLSession.mockDownloadTask.didCancel)

        let events = await eventsTask.value
        #expect(events.contains(.started))
        #expect(events.contains(.cancelled))
    }

    @Test("test cancel from paused state emits cancelled")
    func cancel_fromPaused_emitsCancelled() async throws {
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)
        mockURLSession.mockDownloadTask.mockResumeData = Data("resume".utf8)

        let stream = await sut.downloadFileStream()

        let eventsTask = Task {
            var events: [DownloadEvent] = []
            for await event in stream {
                events.append(event)
            }
            return events
        }

        try await Task.sleep(nanoseconds: 50_000_000)
        try await sut.pause()
        try await Task.sleep(nanoseconds: 50_000_000)
        try await sut.cancel()

        let events = await eventsTask.value
        #expect(events.contains(.started))
        #expect(events.contains(.paused))
        #expect(events.contains(.cancelled))
    }

    // MARK: - Network error

    @Test("test didCompleteWithError emits failed event")
    func downloadFileStream_networkError() async {
        let delegate = SessionDelegate()
        let session = MockSession(urlSession: MockFileDownloaderURLSession(), delegate: delegate)
        let sut = FileDownloader(url: mockUrl, session: session)

        let stream = await sut.downloadFileStream()

        let delegateTask = makeMockDelegateTask()
        delegate.urlSession(.shared, task: delegateTask, didCompleteWithError: URLError(.notConnectedToInternet))

        var events: [DownloadEvent] = []
        for await event in stream {
            events.append(event)
        }

        #expect(events.count == 2)
        #expect(events[0] == .started)
        if case let .failed(error) = events[1],
           case let .downloadFailed(reason) = error,
           case let .urlError(urlError) = reason {
            #expect(urlError.code == .notConnectedToInternet)
        } else {
            Issue.record("Expected .failed with .urlError, got \(events[1])")
        }
    }

    // MARK: - Bad HTTP status

    @Test("test didFinishDownloadingTo with bad HTTP status emits failed")
    func downloadFileStream_badHTTPStatus() async {
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

        #expect(events.count == 2)
        #expect(events[0] == .started)
        if case .failed = events[1] {
            // pass - interceptor detected bad status and emitted .onDownloadFailed
        } else {
            Issue.record("Expected .failed event, got \(events[1])")
        }
    }

    // MARK: - Invalid state transitions

    @Test("test downloadFileStream when already downloading emits alreadyDownloading")
    func downloadFileStream_alreadyDownloading() async {
        let session = MockSession(urlSession: MockFileDownloaderURLSession(), delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        _ = await sut.downloadFileStream()

        let secondStream = await sut.downloadFileStream()
        var events: [DownloadEvent] = []
        for await event in secondStream {
            events.append(event)
        }

        #expect(events.count == 1)
        if case let .failed(error) = events[0],
           case let .downloadFailed(reason) = error {
            #expect(reason == .alreadyDownloading)
        } else {
            Issue.record("Expected .failed(.alreadyDownloading), got \(events[0])")
        }
    }

    @Test("test pause when not downloading throws")
    func pause_whenNotDownloading_throws() async {
        let session = MockSession(urlSession: MockFileDownloaderURLSession(), delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        await #expect(throws: NetworkingError.downloadFailed(reason: .alreadyDownloading)) {
            try await sut.pause()
        }
    }

    @Test("test resume when not paused throws")
    func resume_whenNotPaused_throws() async {
        let session = MockSession(urlSession: MockFileDownloaderURLSession(), delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        await #expect(throws: NetworkingError.downloadFailed(reason: .alreadyDownloading)) {
            try await sut.resume()
        }
    }

    @Test("test cancel when idle throws")
    func cancel_whenIdle_throws() async {
        let session = MockSession(urlSession: MockFileDownloaderURLSession(), delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)

        await #expect(throws: NetworkingError.downloadFailed(reason: .alreadyDownloading)) {
            try await sut.cancel()
        }
    }

    // MARK: - Resume data unavailable

    @Test("test resume with no resume data emits failed and throws cannotResume")
    func resume_noResumeData_emitsFailedAndThrows() async throws {
        let mockURLSession = MockFileDownloaderURLSession()
        let session = MockSession(urlSession: mockURLSession, delegate: SessionDelegate())
        let sut = FileDownloader(url: mockUrl, session: session)
        mockURLSession.mockDownloadTask.mockResumeData = nil

        let stream = await sut.downloadFileStream()

        let eventsTask = Task {
            var events: [DownloadEvent] = []
            for await event in stream {
                events.append(event)
            }
            return events
        }

        try await Task.sleep(nanoseconds: 50_000_000)
        try await sut.pause()
        try await Task.sleep(nanoseconds: 50_000_000)

        await #expect(throws: NetworkingError.downloadFailed(reason: .cannotResume)) {
            try await sut.resume()
        }

        let events = await eventsTask.value
        #expect(events.contains(.started))
        #expect(events.contains(.paused))
        #expect(events.contains(where: {
            if case let .failed(error) = $0,
               case let .downloadFailed(reason) = error {
                return reason == .cannotResume
            }
            return false
        }))
    }
}

// MARK: - DownloadEvent Equatable

extension DownloadEvent: Equatable {
    public static func == (lhs: DownloadEvent, rhs: DownloadEvent) -> Bool {
        switch (lhs, rhs) {
        case (.started, .started),
             (.paused, .paused),
             (.resumed, .resumed),
             (.cancelled, .cancelled):
            true
        case let (.progress(lhsP), .progress(rhsP)):
            lhsP == rhsP
        case let (.completed(lhsURL), .completed(rhsURL)):
            lhsURL == rhsURL
        case let (.failed(lhsE), .failed(rhsE)):
            lhsE == rhsE
        default:
            false
        }
    }
}

// MARK: - Mock URLSessionDownloadTask for delegate calls

private class MockDelegateDownloadTask: URLSessionDownloadTask, @unchecked Sendable {
    private let mockResponse: URLResponse?

    init(mockResponse: URLResponse?) {
        self.mockResponse = mockResponse
        super.init()
    }

    override var response: URLResponse? {
        mockResponse
    }
}
