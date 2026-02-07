import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileDownloadable publishers")
final class FileDownloadablePublisherTests {
    private var cancellables = Set<AnyCancellable>()

    // MARK: SUCCESS

    @Test("test .downloadFilePublisher() Success")
    func downloadFilePublisherSuccess() async {
        let sut = createFileDownloader()
        let expectation = Expectation()

        var didExecute = false
        sut.downloadFilePublisher(from: testURL, progress: nil)
            .sink { completion in
                switch completion {
                case .failure: Issue.record()
                case .finished: expectation.fulfill()
                }
            } receiveValue: { localURL in
                #expect(localURL.absoluteString == "file:///tmp/test.pdf")
                didExecute = true
            }
            .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
        #expect(didExecute)
    }

    // MARK: ERROR - status code

    @Test("test .downloadFilePublisher() Fails When Status Code Is Not 200")
    func downloadFilePublisherFailsWhenStatusCodeIsNot200() async {
        let sut = createFileDownloader(
            urlSession: createMockURLSession(statusCode: 400)
        )
        let expectation = Expectation()
        var didExecute = false
        sut.downloadFilePublisher(from: testURL, progress: nil)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.httpError(HTTPResponse(statusCode: 400)))
                    didExecute = true
                    expectation.fulfill()
                case .finished: Issue.record()
                }
            } receiveValue: { _ in
                Issue.record()
            }
            .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
        #expect(didExecute)
    }

    // MARK: ERROR - validation

    @Test("test .downloadFilePublisher() Fails If Validator Throws Any Error")
    func downloadFilePublisherFailsIfValidatorThrowsAnyError() async {
        let sut = createFileDownloader(
            validator: MockURLResponseValidator(throwError: NetworkingError.couldNotBuildURLRequest(reason: .invalidURL))
        )
        let expectation = Expectation()
        var didExecute = false
        sut.downloadFilePublisher(from: testURL, progress: nil)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.couldNotBuildURLRequest(reason: .invalidURL))
                    didExecute = true
                    expectation.fulfill()
                case .finished: Issue.record()
                }
            } receiveValue: { _ in
                Issue.record()
            }
            .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
        #expect(didExecute)
    }

    // MARK: ERROR - url session

    @Test("test .downloadFilePublisher() Fails When URLSession Has Error")
    func downloadFilePublisherFailsWhenUrlSessionHasError() async {
        let sut = createFileDownloader(
            urlSession: createMockURLSession(error: NetworkingError.httpError(HTTPResponse(statusCode: 500)))
        )
        let expectation = Expectation()
        var didExecute = false
        sut.downloadFilePublisher(from: testURL, progress: nil)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.httpError(HTTPResponse(statusCode: 500)))
                    didExecute = true
                    expectation.fulfill()
                case .finished: Issue.record()
                }
            } receiveValue: { _ in
                Issue.record()
            }
            .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
        #expect(didExecute)
    }

    // MARK: Tracking with callbacks

    @Test("test .downloadFilePublisher() Download Progress Can Be Tracked")
    func downloadFilePublisherTaskDownloadProgressCanBeTracked() async {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()
        let expectation = Expectation()

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
            case .finished: expectation.fulfill()
            }
        } receiveValue: { localURL in
            #expect(localURL.absoluteString == "file:///tmp/test.pdf")
            didExecute = true
        }
        .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
        #expect(didExecute)
        #expect(didTrackProgress)
    }

    @Test("test .downloadFilePublisher() Download Progress Tracking Happens Before Return")
    func downloadFilePublisherTaskDownloadProgressTrackingHappensBeforeReturn() async {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()
        let expectation = Expectation()

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
            case .finished: expectation.fulfill()
            }
        } receiveValue: { _ in
            if didTrackProgressBeforeReturn == nil {
                didTrackProgressBeforeReturn = true
            }
        }
        .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
        #expect(didTrackProgressBeforeReturn == true)
    }

    @Test("test .downloadFilePublisher() Download Progress Tracks Correct Order")
    func downloadFilePublisherTaskDownloadProgressTracksCorrectOrder() async {
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

        sut.downloadFilePublisher(from: testURL) { progress in
            capturedTracking.append(progress)
        }
        .sink { completion in
            switch completion {
            case .failure: Issue.record()
            case .finished: expectation.fulfill()
            }
        } receiveValue: { _ in }
        .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
        #expect(capturedTracking.count == 4)
        #expect(capturedTracking == [0.3, 0.6, 0.9, 1.0])
    }

    // MARK: Tracking with delegate

    @Test("test .downloadFilePublisher() Download Progress Can Be Tracked when Injecting SessionDelegat")
    func downloadFilePublisherTaskDownloadProgressCanBeTrackedWhenInjectingSessionDelegate() async {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()
        let expectation = Expectation()

        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = FileDownloader(
            session: MockSession(urlSession: urlSession, delegate: delegate)
        )

        var didExecute = false
        var didTrackProgress = false

        sut.downloadFilePublisher(from: testURL) { _ in
            didTrackProgress = true
        }
        .sink { completion in
            switch completion {
            case .failure: Issue.record()
            case .finished: expectation.fulfill()
            }
        } receiveValue: { localURL in
            #expect(localURL.absoluteString == "file:///tmp/test.pdf")
            didExecute = true
        }
        .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
        #expect(didExecute)
        #expect(didTrackProgress)
    }

    // MARK: Tracking with Interceptor

    @Test("test .downloadFilePublisher() Download Progress Can Not Be Tracked when Injecting DownloadTaskInterceptor")
    func downloadFilePublisherTaskDownloadProgressCanNotBeTrackedWhenInjectingDownloadTaskInterceptor() async {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()
        let expectation = Expectation()

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
            session: MockSession(urlSession: urlSession, delegate: delegate)
        )

        var didExecute = false

        sut.downloadFilePublisher(from: testURL, progress: nil)
            .sink { completion in
                switch completion {
                case .failure: Issue.record()
                case .finished: expectation.fulfill()
                }
            } receiveValue: { localURL in
                #expect(localURL.absoluteString == "file:///tmp/test.pdf")
                didExecute = true
            }
            .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
        #expect(didExecute)
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
