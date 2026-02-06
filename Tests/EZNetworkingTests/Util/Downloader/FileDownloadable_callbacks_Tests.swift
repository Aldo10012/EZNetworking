import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloadable call backs")
final class FileDownloadableCallBacksTests {
    // MARK: SUCCESS

    @Test("test .downloadFileTask() Success")
    func downloadFileTaskSuccess() async {
        let sut = createFileDownloader()

        let expectation = Expectation()
        sut.downloadFileTask(from: testURL, progress: nil) { result in
            defer { expectation.fulfill() }
            switch result {
            case let .success(localURL):
                #expect(localURL.absoluteString == "file:///tmp/test.pdf")
            case .failure:
                Issue.record()
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: ERROR - status code

    @Test("test .downloadFileTask() Fails When StatusCode Is Not 200")
    func downloadFileFailsWhenStatusCodeIsNot2xx() async {
        let sut = createFileDownloader(
            urlSession: createMockURLSession(statusCode: 400)
        )

        let expectation = Expectation()
        sut.downloadFileTask(from: testURL, progress: nil) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.httpError(HTTPError(statusCode: 400)))
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: ERROR - validation

    @Test("test .downloadFileTask() Fails When Validator Throws Any Error")
    func downloadFileFailsIfValidatorThrowsAnyError() async {
        let sut = createFileDownloader(
            validator: MockURLResponseValidator(throwError: NetworkingError.internalError(.invalidURL))
        )

        let expectation = Expectation()
        sut.downloadFileTask(from: testURL, progress: nil) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.internalError(.invalidURL))
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: ERROR - url session

    @Test("test .downloadFileTask() Fails When urlSession Error Is Not Nil")
    func downloadFileFailsWhenUrlSessionHasError() async {
        let sut = createFileDownloader(
            urlSession: createMockURLSession(error: HTTPError(statusCode: 500))
        )

        let expectation = Expectation()
        sut.downloadFileTask(from: testURL, progress: nil) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 500))))
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: Traching with callback

    @Test("test .downloadFileTask() Download Progress Can Be Tracked")
    func downloadFileTaskDownloadProgressCanBeTracked() async {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        urlSession.progressToExecute = [.inProgress(percent: 50)]

        let sut = FileDownloader(mockSession: urlSession)
        let expectation = Expectation()
        var didTrackProgress = false

        _ = sut.downloadFileTask(from: testURL, progress: { _ in
            didTrackProgress = true
        }, completion: { result in
            defer { expectation.fulfill() }
            switch result {
            case .success: #expect(Bool(true))
            case .failure: Issue.record()
            }
        })
        await expectation.fulfillment(within: .seconds(1))
        #expect(didTrackProgress)
    }

    @Test("test .downloadFileTask() Download Progress Tracking Happens Before Return")
    func downloadFileTaskDownloadProgressTrackingHappensBeforeReturn() async {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()
        let expectation = Expectation()

        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = FileDownloader(mockSession: urlSession)
        var didTrackProgressBeforeReturn: Bool?

        _ = sut.downloadFileTask(from: testURL, progress: { _ in
            if didTrackProgressBeforeReturn == nil {
                didTrackProgressBeforeReturn = true
            }
        }, completion: { result in
            switch result {
            case .success:
                if didTrackProgressBeforeReturn == nil {
                    didTrackProgressBeforeReturn = true
                }
                expectation.fulfill()
            case .failure:
                Issue.record()
            }
        })

        await expectation.fulfillment(within: .seconds(1))
        #expect(didTrackProgressBeforeReturn == true)
    }

    @Test("test .downloadFileTask() Download Progress Tracks Correct Order")
    func downloadFileTaskDownloadProgressTrackingHappensInCorrectOrder() async {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()
        let expectation = Expectation()

        urlSession.progressToExecute = [
            .inProgress(percent: 30),
            .inProgress(percent: 60),
            .inProgress(percent: 90),
            .complete
        ]

        let sut = FileDownloader(mockSession: urlSession)
        var capturedTracking = [Double]()

        _ = sut.downloadFileTask(
            from: testURL,
            progress: { progress in
                capturedTracking.append(progress)
            },
            completion: { _ in
                expectation.fulfill()
            }
        )

        await expectation.fulfillment(within: .seconds(1))
        #expect(capturedTracking.count == 4)
        #expect(capturedTracking == [0.3, 0.6, 0.9, 1.0])
    }

    // MARK: Traching with delegate

    @Test("test .downloadFileTask() Download Progress Can Be Tracked when Injecting SessionDelegat")
    func downloadFileTaskDownloadProgressCanBeTrackedWhenInjectingSessionDelegate() async {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [.inProgress(percent: 50)]

        let sut = FileDownloader(
            session: MockSession(urlSession: urlSession, delegate: delegate)
        )

        let expectation = Expectation()
        var didTrackProgress = false

        _ = sut.downloadFileTask(from: testURL, progress: { _ in
            didTrackProgress = true
        }, completion: { result in
            defer { expectation.fulfill() }
            switch result {
            case .success: #expect(Bool(true))
            case .failure: Issue.record()
            }
        })
        await expectation.fulfillment(within: .seconds(1))
        #expect(didTrackProgress)
    }

    // MARK: Traching with interceptor

    @Test("test .downloadFileTask() Download Progress Can not Be Tracked when Injecting DownloadTaskInterceptor")
    func downloadFileTaskDownloadProgressCanNotBeTrackedWhenInjectingDownloadTaskInterceptor() async {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        var didTrackProgressFromInterceptor = false

        let downloadTaskInterceptor = FileDownloaderMockDownloadTaskInterceptor { _ in
            didTrackProgressFromInterceptor = true
        }
        let delegate = SessionDelegate(
            downloadTaskInterceptor: downloadTaskInterceptor
        )
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [.inProgress(percent: 50)]

        let sut = FileDownloader(
            session: MockSession(urlSession: urlSession, delegate: delegate)
        )

        let expectation = Expectation()

        _ = sut.downloadFileTask(from: testURL, progress: nil) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success: #expect(Bool(true))
            case .failure: Issue.record()
            }
        }
        await expectation.fulfillment(within: .seconds(1))
        #expect(!didTrackProgressFromInterceptor)
        #expect(downloadTaskInterceptor.didCallDidWriteData)
    }
}

// MARK: helpers

private let testURL = URL(string: "https://example.com/example.pdf")!

private func createFileDownloader(
    urlSession: URLSessionProtocol = createMockURLSession(statusCode: 200),
    validator: ResponseValidator = ResponseValidatorImpl(),
    decoder: JSONDecoder = EZJSONDecoder()
) -> FileDownloader {
    FileDownloader(
        session: MockSession(urlSession: urlSession),
        validator: validator,
        decoder: decoder
    )
}

private func createMockURLSession(
    url: URL = testURL,
    statusCode: Int = 200,
    error: Error? = nil
) -> MockFileDownloaderURLSession {
    MockFileDownloaderURLSession(
        url: url,
        urlResponse: buildResponse(statusCode: statusCode),
        error: error
    )
}

private func buildResponse(statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(
        url: URL(string: "https://example.com")!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
    )!
}
