import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloadable call backs")
final class FileDownloadableCallBacksTests {
    // MARK: SUCCESS

    @Test("test .downloadFileTask() Success")
    func downloadFileTaskSuccess() {
        let sut = createFileDownloader()

        var didExecute = false
        sut.downloadFileTask(from: testURL, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case let .success(localURL):
                #expect(localURL.absoluteString == "file:///tmp/test.pdf")
            case .failure:
                Issue.record()
            }
        }
        #expect(didExecute)
    }

    // MARK: Task Cancellation

    @Test("test .downloadFileTask() Can Cancel")
    func downloadFileCanCancel() throws {
        let sut = createFileDownloader()

        let task = sut.downloadFileTask(from: testURL, progress: nil) { _ in }
        task.cancel()
        let downloadTask = try #require(task as? MockURLSessionDownloadTask)
        #expect(downloadTask.didCancel)
    }

    // MARK: ERROR - status code

    @Test("test .downloadFileTask() Fails When StatusCode Is Not 200")
    func downloadFileFailsWhenStatusCodeIsNot2xx() {
        let sut = createFileDownloader(
            urlSession: createMockURLSession(statusCode: 400)
        )

        var didExecute = false
        sut.downloadFileTask(from: testURL, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.httpError(HTTPError(statusCode: 400)))
            }
        }
        #expect(didExecute)
    }

    // MARK: ERROR - validation

    @Test("test .downloadFileTask() Fails When Validator Throws Any Error")
    func downloadFileFailsIfValidatorThrowsAnyError() {
        let sut = createFileDownloader(
            validator: MockURLResponseValidator(throwError: NetworkingError.internalError(.noData))
        )

        var didExecute = false
        sut.downloadFileTask(from: testURL, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.internalError(.noData))
            }
        }
        #expect(didExecute)
    }

    // MARK: ERROR - url session

    @Test("test .downloadFileTask() Fails When urlSession Error Is Not Nil")
    func downloadFileFailsWhenUrlSessionHasError() {
        let sut = createFileDownloader(
            urlSession: createMockURLSession(error: HTTPError(statusCode: 500))
        )

        var didExecute = false
        sut.downloadFileTask(from: testURL, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 500))))
            }
        }
        #expect(didExecute)
    }

    // MARK: Traching with callback

    @Test("test .downloadFileTask() Download Progress Can Be Tracked")
    func downloadFileTaskDownloadProgressCanBeTracked() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        urlSession.progressToExecute = [.inProgress(percent: 50)]

        let sut = FileDownloader(mockSession: urlSession)
        var didExecute = false
        var didTrackProgress = false

        _ = sut.downloadFileTask(from: testURL, progress: { _ in
            didTrackProgress = true
        }, completion: { result in
            defer { didExecute = true }
            switch result {
            case .success: #expect(true)
            case .failure: Issue.record()
            }
        })
        #expect(didExecute)
        #expect(didTrackProgress)
    }

    @Test("test .downloadFileTask() Download Progress Tracking Happens Before Return")
    func downloadFileTaskDownloadProgressTrackingHappensBeforeReturn() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

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
            case .failure:
                Issue.record()
            }
        })
        #expect(didTrackProgressBeforeReturn == true)
    }

    @Test("test .downloadFileTask() Download Progress Tracks Correct Order")
    func downloadFileTaskDownloadProgressTrackingHappensInCorrectOrder() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

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
            completion: { _ in }
        )

        #expect(capturedTracking.count == 4)
        #expect(capturedTracking == [0.3, 0.6, 0.9, 1.0])
    }

    // MARK: Traching with delegate

    @Test("test .downloadFileTask() Download Progress Can Be Tracked when Injecting SessionDelegat")
    func downloadFileTaskDownloadProgressCanBeTrackedWhenInjectingSessionDelegate() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [.inProgress(percent: 50)]

        let sut = FileDownloader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )

        var didExecute = false
        var didTrackProgress = false

        _ = sut.downloadFileTask(from: testURL, progress: { _ in
            didTrackProgress = true
        }, completion: { result in
            defer { didExecute = true }
            switch result {
            case .success: #expect(true)
            case .failure: Issue.record()
            }
        })
        #expect(didExecute)
        #expect(didTrackProgress)
    }

    // MARK: Traching with interceptor

    @Test("test .downloadFileTask() Download Progress Can Be Tracked when Injecting DownloadTaskInterceptor")
    func downloadFileTaskDownloadProgressCanBeTrackedWhenInjectingDownloadTaskInterceptor() {
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
            urlSession: urlSession,
            sessionDelegate: delegate
        )

        var didExecute = false

        _ = sut.downloadFileTask(from: testURL, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success: #expect(true)
            case .failure: Issue.record()
            }
        }
        #expect(didExecute)
        #expect(didTrackProgressFromInterceptor)
        #expect(downloadTaskInterceptor.didCallDidWriteData)
    }
}

// MARK: helpers

private let testURL = URL(string: "https://example.com/example.pdf")!

private func createFileDownloader(
    urlSession: URLSessionTaskProtocol = createMockURLSession(statusCode: 200),
    validator: ResponseValidator = ResponseValidatorImpl(),
    requestDecoder: RequestDecodable = RequestDecoder()
) -> FileDownloader {
    FileDownloader(
        urlSession: urlSession,
        validator: validator,
        requestDecoder: requestDecoder
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
