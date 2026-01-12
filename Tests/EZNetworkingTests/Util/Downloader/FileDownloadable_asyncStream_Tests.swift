import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloadable async stream")
final class FileDownloadable_AsyncStream_Tests {

    // MARK: SUCCESS

    @Test("test .downloadFileStream() Success")
    func testDownloadFileStreamSuccess() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()
        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        let sut = FileDownloader(
            urlSession: urlSession,
            validator: ResponseValidatorImpl(),
            requestDecoder: RequestDecoder(),
            sessionDelegate: delegate
        )

        var events: [DownloadStreamEvent] = []
        for await event in sut.downloadFileStream(from: testURL) {
            events.append(event)
        }

        #expect(events.count == 1)
        switch events[0] {
        case .success(let url):
            #expect(url.absoluteString == "file:///tmp/test.pdf")
        default:
            Issue.record()
        }
    }

    // MARK: ERROR - status code

    @Test("test .downloadFileStream() Fails When StatusCode Is Not 200")
    func testDownloadFileStreamFailsWhenStatusCodeIsNot200() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let sut = FileDownloader(
            urlSession: createMockURLSession(statusCode: 400),
            validator: ResponseValidatorImpl()
        )

        var events: [DownloadStreamEvent] = []
        for await event in sut.downloadFileStream(from: testURL) {
            events.append(event)
        }

        #expect(events.count == 1)
        switch events[0] {
        case .failure(let error):
            #expect(error == NetworkingError.httpError(HTTPError(statusCode: 400)))
        default:
            Issue.record()
        }
    }

    // MARK: ERROR - validation

    @Test("test .downloadFileStream() Fails When Validator Throws AnyError")
    func testDownloadFileStreamFailsWhenValidatorThrowsAnyError() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let sut = FileDownloader(
            urlSession: createMockURLSession(),
            validator: MockURLResponseValidator(throwError: NetworkingError.internalError(.noData))
        )

        var events: [DownloadStreamEvent] = []
        for await event in sut.downloadFileStream(from: testURL) {
            events.append(event)
        }

        #expect(events.count == 1)
        switch events[0] {
        case .failure(let error):
            #expect(error == NetworkingError.internalError(.noData))
        default:
            Issue.record()
        }
    }

    // MARK: ERROR - urlSession

    @Test("test .downloadFileStream() Fails When urlSession Error Is Not Nil")
    func testDownloadFileStreamFailsWhenErrorIsNotNil() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let sut = FileDownloader(
            urlSession: createMockURLSession(error: NetworkingError.internalError(.unknown))
        )

        var events: [DownloadStreamEvent] = []
        for await event in sut.downloadFileStream(from: testURL) {
            events.append(event)
        }

        #expect(events.count == 1)
        switch events[0] {
        case .failure(let error):
            #expect(error == NetworkingError.internalError(.requestFailed(NetworkingError.internalError(.unknown))))
        default:
            Issue.record()
        }
    }

    // MARK: Tracking

    @Test("test .downloadFileStream() Download Progress Can Be Tracked")
    func testDownloadFileStreamDownloadProgressCanBeTracked() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = FileDownloader(mockSession: urlSession)
        var didTrackProgress = false

        for await event in sut.downloadFileStream(from: testURL) {
            switch event {
            case .progress:
                didTrackProgress = true
            case .success: break
            case .failure: Issue.record()
            }
        }

        #expect(didTrackProgress)
    }

    @Test("test .downloadFileStream() Download Progress Tracking Happens Before Final Result")
    func testDownloadFileStreamDownloadProgressTrackingHappensBeforeFinalResult() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = FileDownloader(mockSession: urlSession)
        var didTrackProgressBeforeReturn: Bool? = nil
        var numberOfEvents = 0

        for await event in sut.downloadFileStream(from: testURL) {
            switch event {
            case .progress:
                numberOfEvents += 1
                if didTrackProgressBeforeReturn == nil {
                    didTrackProgressBeforeReturn = true
                }
            case .success:
                numberOfEvents += 1
                if didTrackProgressBeforeReturn == nil {
                    didTrackProgressBeforeReturn = false
                }
            default:
                Issue.record()
            }
        }

        #expect(numberOfEvents == 2)
        #expect(didTrackProgressBeforeReturn == true)
    }

    @Test("test .downloadFileStream() Download Progress Tracking Order")
    func testDownloadFileStreamDownloadProgressTrackingOrder() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        urlSession.progressToExecute = [
            .inProgress(percent: 30),
            .inProgress(percent: 60),
            .inProgress(percent: 90),
            .complete
        ]

        let sut = FileDownloader(mockSession: urlSession)
        var progressValues: [Double] = []
        var didReceiveSuccess = false

        for await event in sut.downloadFileStream(from: testURL) {
            switch event {
            case .progress(let value):
                progressValues.append(value)
            case .success:
                didReceiveSuccess = true
            default:
                Issue.record()
            }
        }

        #expect(progressValues == [0.3, 0.6, 0.9, 1.0])
        #expect(didReceiveSuccess)
    }

    // MARK: Traching with delegate

    @Test("test .downloadFileStream() Download Progress Can Be Tracked when Injecting SessionDelegat")
    func testDownloadFileStreamDownloadProgressCanBeTrackedWhenInjectingSessionDelegate() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = FileDownloader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )

        var didTrackProgress = false

        for await event in sut.downloadFileStream(from: testURL) {
            switch event {
            case .progress:
                didTrackProgress = true
            case .success: break
            case .failure: Issue.record()
            }
        }

        #expect(didTrackProgress)
    }

    // MARK: Traching with interceptor

    @Test("test .downloadFileStream() Download Progress Can Be Tracked when Injecting DownloadTaskInterceptor")
    func testDownloadFileStreamDownloadProgressCanBeTrackedWhenInjectingDownloadTaskInterceptor() async throws {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        var didTrackProgressStreamEvent = false
        var didTrackProgressFromInterceptorClosure = false
        let downloadTaskInterceptor = FileDownloader_MockDownloadTaskInterceptor(progress: { _ in
            didTrackProgressFromInterceptorClosure = true
        })
        let delegate = SessionDelegate(
            downloadTaskInterceptor: downloadTaskInterceptor
        )
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = FileDownloader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )


        for await event in sut.downloadFileStream(from: testURL) {
            switch event {
            case .progress: didTrackProgressStreamEvent = true
            case .success: break
            case .failure: Issue.record()
            }
        }

        #expect(downloadTaskInterceptor.didCallDidWriteData)
        #expect(didTrackProgressStreamEvent)
        #expect(didTrackProgressFromInterceptorClosure == false) // closure inside of interceptor gets overwritten
    }

}

// MARK: helpers

private let testURL = URL(string: "https://example.com/example.pdf")!

private func createMockURLSession(
    url: URL = testURL,
    statusCode: Int = 200,
    error: Error? = nil
) -> MockFileDownloaderURLSession {
    return MockFileDownloaderURLSession(
        url: url,
        urlResponse: buildResponse(statusCode: statusCode),
        error: error
    )
}

private func buildResponse(statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(url: URL(string: "https://example.com")!,
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil)!
}
