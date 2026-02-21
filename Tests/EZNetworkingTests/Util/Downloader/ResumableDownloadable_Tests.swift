@testable import EZNetworking
import Foundation
import Testing

@Suite("Test ResumableDownloadable")
final class ResumableDownloadableTests {
    // MARK: SUCCESS - basic download

    @Test("test .downloadFileStream() emits started then completed")
    func downloadFileStreamSuccess() async {
        let urlSession = createMockURLSession()
        urlSession.progressToExecute = [.complete]
        let sut = createResumableDownloader(urlSession: urlSession)

        let expectation = Expectation()
        var events: [String] = []

        Task {
            for await event in await sut.downloadFileStream() {
                switch event {
                case .started:
                    events.append("started")
                case let .completed(url):
                    events.append("completed")
                    #expect(url.absoluteString == "file:///tmp/test.pdf")
                    expectation.fulfill()
                case let .progress(value):
                    events.append("progress(\(value))")
                default:
                    break
                }
            }
        }

        await expectation.fulfillment(within: .seconds(3))
        #expect(events.first == "started")
        #expect(events.last == "completed")
    }

    // MARK: SUCCESS - progress tracking

    @Test("test .downloadFileStream() emits progress events")
    func downloadFileStreamProgress() async {
        let urlSession = createMockURLSession()
        urlSession.progressToExecute = [
            .inProgress(percent: 50),
            .complete
        ]
        let sut = createResumableDownloader(urlSession: urlSession)

        let expectation = Expectation()
        var progressValues: [Double] = []

        Task {
            for await event in await sut.downloadFileStream() {
                switch event {
                case let .progress(value):
                    progressValues.append(value)
                case .completed:
                    expectation.fulfill()
                default:
                    break
                }
            }
        }

        await expectation.fulfillment(within: .seconds(3))
        #expect(progressValues.contains(0.5))
    }

    @Test("test .downloadFileStream() emits progress events in correct order")
    func downloadFileStreamProgressOrder() async {
        let urlSession = createMockURLSession()
        urlSession.progressToExecute = [
            .inProgress(percent: 30),
            .inProgress(percent: 60),
            .inProgress(percent: 90),
            .complete
        ]
        let sut = createResumableDownloader(urlSession: urlSession)

        let expectation = Expectation()
        var progressValues: [Double] = []

        Task {
            for await event in await sut.downloadFileStream() {
                switch event {
                case let .progress(value):
                    progressValues.append(value)
                case .completed:
                    expectation.fulfill()
                default:
                    break
                }
            }
        }

        await expectation.fulfillment(within: .seconds(3))
        #expect(progressValues == [0.3, 0.6, 0.9])
    }

    // MARK: - cancel

    @Test("test .cancel() emits cancelled event")
    func cancelEmitsCancelledEvent() async {
        let urlSession = createMockURLSession()
        let sut = createResumableDownloader(urlSession: urlSession)

        let expectation = Expectation()
        var didReceiveStarted = false
        var didReceiveCancelled = false

        Task {
            for await event in await sut.downloadFileStream() {
                switch event {
                case .started:
                    didReceiveStarted = true
                    await sut.cancel()
                case .cancelled:
                    didReceiveCancelled = true
                    expectation.fulfill()
                default:
                    break
                }
            }
        }

        await expectation.fulfillment(within: .seconds(3))
        #expect(didReceiveStarted)
        #expect(didReceiveCancelled)
    }

    // MARK: - pause

    @Test("test .pause() emits paused event")
    func pauseEmitsPausedEvent() async {
        let urlSession = createMockURLSession()
        let mockTask = MockURLSessionDownloadTaskProtocol()
        mockTask.resumeDataToReturn = Data("resume".utf8)
        urlSession.mockDownloadTask = mockTask
        let sut = createResumableDownloader(urlSession: urlSession)

        let expectation = Expectation()
        var didReceivePaused = false

        Task {
            for await event in await sut.downloadFileStream() {
                switch event {
                case .started:
                    await sut.pause()
                case .paused:
                    didReceivePaused = true
                    expectation.fulfill()
                default:
                    break
                }
            }
        }

        await expectation.fulfillment(within: .seconds(3))
        #expect(didReceivePaused)
    }

    // MARK: - resume after pause

    @Test("test .resume() after pause emits resumed event and completes")
    func resumeAfterPauseEmitsResumedEvent() async {
        let urlSession = createMockURLSession()
        let mockTask = MockURLSessionDownloadTaskProtocol()
        mockTask.resumeDataToReturn = Data("resume".utf8)
        urlSession.mockDownloadTask = mockTask
        let sut = createResumableDownloader(urlSession: urlSession)

        let expectation = Expectation()
        var receivedEvents: [String] = []

        Task {
            for await event in await sut.downloadFileStream() {
                switch event {
                case .started:
                    receivedEvents.append("started")
                    await sut.pause()
                case .paused:
                    receivedEvents.append("paused")
                    urlSession.progressToExecute = [.complete]
                    await sut.resume()
                case .resumed:
                    receivedEvents.append("resumed")
                case .completed:
                    receivedEvents.append("completed")
                    expectation.fulfill()
                default:
                    break
                }
            }
        }

        await expectation.fulfillment(within: .seconds(3))
        #expect(receivedEvents == ["started", "paused", "resumed", "completed"])
    }

    @Test("test .resume() uses resume data when available")
    func resumeUsesResumeData() async {
        let urlSession = createMockURLSession()
        let mockTask = MockURLSessionDownloadTaskProtocol()
        mockTask.resumeDataToReturn = Data("resume".utf8)
        urlSession.mockDownloadTask = mockTask
        let sut = createResumableDownloader(urlSession: urlSession)

        let expectation = Expectation()

        Task {
            for await event in await sut.downloadFileStream() {
                switch event {
                case .started:
                    await sut.pause()
                case .paused:
                    urlSession.progressToExecute = [.complete]
                    await sut.resume()
                case .completed:
                    expectation.fulfill()
                default:
                    break
                }
            }
        }

        await expectation.fulfillment(within: .seconds(3))
        #expect(urlSession.didCreateTaskFromResumeData)
    }

    // MARK: - failure

    @Test("test .downloadFileStream() emits failed event on error")
    func downloadFileStreamFailure() async {
        let urlSession = createMockURLSession()
        urlSession.progressToExecute = [.failed(URLError(.networkConnectionLost))]
        let sut = createResumableDownloader(urlSession: urlSession)

        let expectation = Expectation()
        var didReceiveStarted = false
        var didReceiveFailed = false
        var receivedError: NetworkingError?

        Task {
            for await event in await sut.downloadFileStream() {
                switch event {
                case .started:
                    didReceiveStarted = true
                case let .failed(error):
                    didReceiveFailed = true
                    receivedError = error
                    expectation.fulfill()
                default:
                    break
                }
            }
        }

        await expectation.fulfillment(within: .seconds(3))
        #expect(didReceiveStarted)
        #expect(didReceiveFailed)
        #expect(receivedError == .requestFailed(reason: .urlError(underlying: URLError(.networkConnectionLost))))
    }

    @Test("test .downloadFileStream() emits progress then failed when error occurs mid-download")
    func downloadFileStreamProgressThenFailure() async {
        let urlSession = createMockURLSession()
        urlSession.progressToExecute = [
            .inProgress(percent: 30),
            .inProgress(percent: 60),
            .failed(URLError(.timedOut))
        ]
        let sut = createResumableDownloader(urlSession: urlSession)

        let expectation = Expectation()
        var events: [String] = []

        Task {
            for await event in await sut.downloadFileStream() {
                switch event {
                case .started:
                    events.append("started")
                case let .progress(value):
                    events.append("progress(\(value))")
                case .failed:
                    events.append("failed")
                    expectation.fulfill()
                default:
                    break
                }
            }
        }

        await expectation.fulfillment(within: .seconds(3))
        #expect(events == ["started", "progress(0.3)", "progress(0.6)", "failed"])
    }

    // MARK: - no-op scenarios

    @Test("test .pause() does nothing when state is idle")
    func pauseDoesNothingWhenIdle() async {
        let urlSession = createMockURLSession()
        let sut = createResumableDownloader(urlSession: urlSession)

        // Pause before starting should be a no-op (no crash)
        await sut.pause()
    }

    @Test("test .resume() does nothing when state is idle")
    func resumeDoesNothingWhenIdle() async {
        let urlSession = createMockURLSession()
        let sut = createResumableDownloader(urlSession: urlSession)

        // Resume before starting should be a no-op (no crash)
        await sut.resume()
    }
}

// MARK: helpers

private let testURL = URL(string: "https://example.com/example.pdf")!

private func createMockURLSession() -> MockResumableDownloaderURLSession {
    MockResumableDownloaderURLSession()
}

private func createResumableDownloader(
    urlSession: MockResumableDownloaderURLSession,
    validator: ResponseValidator = DefaultResponseValidator()
) -> ResumableDownloader {
    let delegate = SessionDelegate()
    urlSession.sessionDelegate = delegate
    return ResumableDownloader(
        from: testURL,
        session: MockSession(urlSession: urlSession, delegate: delegate),
        validator: validator
    )
}
