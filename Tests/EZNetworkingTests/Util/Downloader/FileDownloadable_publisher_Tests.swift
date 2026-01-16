import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloadable publishers")
final class FileDownloadablePublisherTests {
    private var cancellables = Set<AnyCancellable>()

    // MARK: SUCCESS

    @Test("test .downloadFilePublisher() Success")
    func downloadFilePublisherSuccess() {
        let sut = createFileDownloader()

        var didExecute = false
        sut.downloadFilePublisher(from: testURL, progress: nil)
            .sink { completion in
                switch completion {
                case .failure: Issue.record()
                case .finished: break
                }
            } receiveValue: { localURL in
                #expect(localURL.absoluteString == "file:///tmp/test.pdf")
                didExecute = true
            }
            .store(in: &cancellables)

        #expect(didExecute)
    }

    // MARK: ERROR - status code

    @Test("test .downloadFilePublisher() Fails When Status Code Is Not 200")
    func downloadFilePublisherFailsWhenStatusCodeIsNot200() {
        let sut = createFileDownloader(
            urlSession: createMockURLSession(statusCode: 400)
        )

        var didExecute = false
        sut.downloadFilePublisher(from: testURL, progress: nil)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.httpError(HTTPError(statusCode: 400)))
                    didExecute = true
                case .finished: Issue.record()
                }
            } receiveValue: { _ in
                Issue.record()
            }
            .store(in: &cancellables)

        #expect(didExecute)
    }

    // MARK: ERROR - validation

    @Test("test .downloadFilePublisher() Fails If Validator Throws Any Error")
    func downloadFilePublisherFailsIfValidatorThrowsAnyError() {
        let sut = createFileDownloader(
            validator: MockURLResponseValidator(throwError: NetworkingError.internalError(.noData))
        )

        var didExecute = false
        sut.downloadFilePublisher(from: testURL, progress: nil)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.internalError(.noData))
                    didExecute = true
                case .finished: Issue.record()
                }
            } receiveValue: { _ in
                Issue.record()
            }
            .store(in: &cancellables)

        #expect(didExecute)
    }

    // MARK: ERROR - url session

    @Test("test .downloadFilePublisher() Fails When URLSession Has Error")
    func downloadFilePublisherFailsWhenUrlSessionHasError() {
        let sut = createFileDownloader(
            urlSession: createMockURLSession(error: HTTPError(statusCode: 500))
        )

        var didExecute = false
        sut.downloadFilePublisher(from: testURL, progress: nil)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 500))))
                    didExecute = true
                case .finished: Issue.record()
                }
            } receiveValue: { _ in
                Issue.record()
            }
            .store(in: &cancellables)

        #expect(didExecute)
    }

    // MARK: Tracking with callbacks

    @Test("test .downloadFilePublisher() Download Progress Can Be Tracked")
    func downloadFilePublisherTaskDownloadProgressCanBeTracked() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = FileDownloader(mockSession: urlSession)
        var didExecute = false
        var didTrackProgress = false

        sut.downloadFilePublisher(from: testURL) { _ in
            didTrackProgress = true
        }
        .sink { completion in
            switch completion {
            case .failure: Issue.record()
            case .finished: break
            }
        } receiveValue: { localURL in
            #expect(localURL.absoluteString == "file:///tmp/test.pdf")
            didExecute = true
        }
        .store(in: &cancellables)

        #expect(didExecute)
        #expect(didTrackProgress)
    }

    @Test("test .downloadFilePublisher() Download Progress Tracking Happens Before Return")
    func downloadFilePublisherTaskDownloadProgressTrackingHappensBeforeReturn() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = FileDownloader(mockSession: urlSession)
        var didTrackProgressBeforeReturn: Bool?

        sut.downloadFilePublisher(from: testURL) { _ in
            if didTrackProgressBeforeReturn == nil {
                didTrackProgressBeforeReturn = true
            }
        }
        .sink { completion in
            switch completion {
            case .failure: Issue.record()
            case .finished: break
            }
        } receiveValue: { _ in
            if didTrackProgressBeforeReturn == nil {
                didTrackProgressBeforeReturn = true
            }
        }
        .store(in: &cancellables)

        #expect(didTrackProgressBeforeReturn == true)
    }

    @Test("test .downloadFilePublisher() Download Progress Tracks Correct Order")
    func downloadFilePublisherTaskDownloadProgressTracksCorrectOrder() {
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

        sut.downloadFilePublisher(from: testURL) { progress in
            capturedTracking.append(progress)
        }
        .sink { completion in
            switch completion {
            case .failure: Issue.record()
            case .finished: break
            }
        } receiveValue: { _ in }
        .store(in: &cancellables)

        #expect(capturedTracking.count == 4)
        #expect(capturedTracking == [0.3, 0.6, 0.9, 1.0])
    }

    // MARK: Tracking with delegate

    @Test("test .downloadFilePublisher() Download Progress Can Be Tracked when Injecting SessionDelegat")
    func downloadFilePublisherTaskDownloadProgressCanBeTrackedWhenInjectingSessionDelegate() {
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

        var didExecute = false
        var didTrackProgress = false

        sut.downloadFilePublisher(from: testURL) { _ in
            didTrackProgress = true
        }
        .sink { completion in
            switch completion {
            case .failure: Issue.record()
            case .finished: break
            }
        } receiveValue: { localURL in
            #expect(localURL.absoluteString == "file:///tmp/test.pdf")
            didExecute = true
        }
        .store(in: &cancellables)

        #expect(didExecute)
        #expect(didTrackProgress)
    }

    // MARK: Tracking with Interceptor

    @Test("test .downloadFilePublisher() Download Progress Can Be Tracked when Injecting DownloadTaskInterceptor")
    func downloadFilePublisherTaskDownloadProgressCanBeTrackedWhenInjectingDownloadTaskInterceptor() {
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
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = FileDownloader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )

        var didExecute = false

        sut.downloadFilePublisher(from: testURL, progress: nil)
            .sink { completion in
                switch completion {
                case .failure: Issue.record()
                case .finished: break
                }
            } receiveValue: { localURL in
                #expect(localURL.absoluteString == "file:///tmp/test.pdf")
                didExecute = true
            }
            .store(in: &cancellables)

        #expect(didExecute)
        #expect(didTrackProgressFromInterceptor)
        #expect(downloadTaskInterceptor.didCallDidWriteData)
    }
}

// MARK: helpers

private let testURL = URL(string: "https://example.com/example.pdf")!

private func createFileDownloader(
    urlSession: URLSessionProtocol = createMockURLSession(statusCode: 200),
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
