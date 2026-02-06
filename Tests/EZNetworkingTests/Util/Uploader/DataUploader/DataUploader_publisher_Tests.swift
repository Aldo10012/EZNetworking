import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DataUploader publishers")
final class DataUploaderPublisherTests {
    private var cancellables = Set<AnyCancellable>()

    // MARK: SUCCESS

    @Test("test .uploadDataPublisher() Success")
    func uploadDataPublisher_Success() async {
        let sut = createDataUploader()

        let expectation = Expectation()
        sut.uploadDataPublisher(mockData, with: mockRequest, progress: nil)
            .sink { completion in
                switch completion {
                case .failure: Issue.record()
                case .finished: break
                }
            } receiveValue: { _ in
                #expect(Bool(true))
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: ERROR - status code

    @Test("test .uploadDataPublisher() Fails When Status Code Is Not 200")
    func uploadDataPublisher_FailsWhenStatusCodeIsNot200() async {
        let sut = createDataUploader(
            urlSession: createMockURLSession(urlResponse: buildResponse(statusCode: 400))
        )

        let expectation = Expectation()
        sut.uploadDataPublisher(mockData, with: mockRequest, progress: nil)
            .sink { completion in
                switch completion {
                case let .failure(error):
                   if case .responseValidationFailure(reason: .badHTTPResponse(underlying: let httpError)) = error {
                #expect(httpError.statusCode == 400)
            } else {
                Issue.record("Unexpected error")
            }
                    expectation.fulfill()
                case .finished: Issue.record()
                }
            } receiveValue: { _ in
                Issue.record()
            }
            .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: ERROR - url session

    @Test("test .uploadDataPublisher() Fails When URLSession Has Error")
    func uploadDataPublisher_FailsWhenUrlSessionHasError() async {
        let sut = createDataUploader(
            urlSession: createMockURLSession(error: HTTPError(statusCode: 500))
        )

        let expectation = Expectation()
        sut.uploadDataPublisher(mockData, with: mockRequest, progress: nil)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 500))))
                    expectation.fulfill()
                case .finished: Issue.record()
                }
            } receiveValue: { _ in
                Issue.record()
            }
            .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("test .uploadDataPublisher() Fails When URLSession Has URLError")
    func uploadDataPublisher_FailsWhenUrlSessionHasURLError() async {
        let sut = createDataUploader(
            urlSession: createMockURLSession(error: URLError(.notConnectedToInternet))
        )

        let expectation = Expectation()
        sut.uploadDataPublisher(mockData, with: mockRequest, progress: nil)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    #expect(error == NetworkingError.urlError(URLError(.notConnectedToInternet)))
                    expectation.fulfill()
                case .finished: Issue.record()
                }
            } receiveValue: { _ in
                Issue.record()
            }
            .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: Tracking with callbacks

    @Test("test .uploadDataPublisher() Download Progress Can Be Tracked")
    func uploadDataPublisher_ProgressCanBeTracked() async {
        let urlSession = createMockURLSession()

        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = DataUploader(mockSession: urlSession)
        let expectation = Expectation()
        var didTrackProgress = false

        sut.uploadDataPublisher(mockData, with: mockRequest) { _ in
            didTrackProgress = true
        }
        .sink { completion in
            switch completion {
            case .failure: Issue.record()
            case .finished: break
            }
        } receiveValue: { _ in
            expectation.fulfill()
        }
        .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
        #expect(didTrackProgress)
    }

    @Test("test .uploadDataPublisher() Download Progress Tracking Happens Before Return")
    func uploadDataPublisher_ProgressTrackingHappensBeforeReturn() async {
        let urlSession = createMockURLSession()
        let expectation = Expectation()

        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = DataUploader(mockSession: urlSession)
        var progressAndReturnList = [String]()

        sut.uploadDataPublisher(mockData, with: mockRequest) { _ in
            progressAndReturnList.append("did track progress")
        }
        .sink { completion in
            switch completion {
            case .failure: Issue.record()
            case .finished: expectation.fulfill()
            }
        } receiveValue: { _ in
            progressAndReturnList.append("did return")
        }
        .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
        #expect(progressAndReturnList.count == 2)
        #expect(progressAndReturnList[0] == "did track progress")
        #expect(progressAndReturnList[1] == "did return")
    }

    @Test("test .uploadDataPublisher() Download Progress Tracks Correct Order")
    func uploadDataPublisher_ProgressTracksCorrectOrder() async {
        let urlSession = createMockURLSession()
        let expectation = Expectation()

        urlSession.progressToExecute = [
            .inProgress(percent: 30),
            .inProgress(percent: 60),
            .inProgress(percent: 90),
            .complete
        ]

        let sut = DataUploader(mockSession: urlSession)
        var capturedTracking = [Double]()

        sut.uploadDataPublisher(mockData, with: mockRequest) { progress in
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

    @Test("test .uploadDataPublisher() Download Progress Can Be Tracked when Injecting SessionDelegat")
    func uploadDataPublisher_ProgressCanBeTrackedWhenInjectingSessionDelegate() async {
        let urlSession = createMockURLSession()

        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = DataUploader(
            session: MockSession(urlSession: urlSession, delegate: delegate)
        )

        let expectation = Expectation()
        var didTrackProgress = false

        sut.uploadDataPublisher(mockData, with: mockRequest) { _ in
            didTrackProgress = true
        }
        .sink { completion in
            switch completion {
            case .failure: Issue.record()
            case .finished: break
            }
        } receiveValue: { _ in
            expectation.fulfill()
        }
        .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
        #expect(didTrackProgress)
    }

    // MARK: Tracking with Interceptor

    @Test("test .uploadDataPublisher() Download Progress Can Not Be Tracked when Injecting DownloadTaskInterceptor")
    func uploadDataPublisher_DownloadFilePublisherTaskDownloadProgressCanNotBeTrackedWhenInjectingDownloadTaskInterceptor() async {
        let urlSession = createMockURLSession()

        var didTrackProgressFromInterceptor = false

        let uploadInterceptor = MockUploadTaskInterceptor { _ in
            didTrackProgressFromInterceptor = true
        }
        let delegate = SessionDelegate(
            uploadTaskInterceptor: uploadInterceptor
        )
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = DataUploader(
            session: MockSession(urlSession: urlSession, delegate: delegate)
        )

        let expectation = Expectation()

        sut.uploadDataPublisher(mockData, with: mockRequest, progress: nil)
            .sink { completion in
                switch completion {
                case .failure: Issue.record()
                case .finished: break
                }
            } receiveValue: { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await expectation.fulfillment(within: .seconds(1))
        #expect(!didTrackProgressFromInterceptor)
        #expect(uploadInterceptor.didCallDidSendBodyData)
    }
}

// MARK: - helpers

private func createDataUploader(
    urlSession: URLSessionProtocol = createMockURLSession()
) -> DataUploader {
    DataUploader(session: MockSession(urlSession: urlSession))
}

private func createMockURLSession(
    data: Data? = Data(),
    urlResponse: URLResponse? = buildResponse(statusCode: 200),
    error: Error? = nil
) -> MockDataUploaderURLSession {
    MockDataUploaderURLSession(data: data, urlResponse: urlResponse, error: error)
}

private func buildResponse(statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(
        url: URL(string: "https://example.com")!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
    )!
}

private struct MockRequest: Request {
    var httpMethod: HTTPMethod { .GET }
    var baseUrl: String { "https://www.example.com" }
    var parameters: [HTTPParameter]? { nil }
    var headers: [HTTPHeader]? { nil }
    var body: HTTPBody? { nil }
}

extension DataUploader {
    /// Test-only initializer that mimics the production logic but uses MockFileDownloaderURLSession.
    fileprivate convenience init(
        mockSession: MockDataUploaderURLSession,
        validator: ResponseValidator = ResponseValidatorImpl(),
        decoder: JSONDecoder = EZJSONDecoder()
    ) {
        let sessionDelegate = SessionDelegate()
        mockSession.sessionDelegate = sessionDelegate
        self.init(
            session: MockSession(urlSession: mockSession, delegate: sessionDelegate),
            validator: validator
        )
    }
}

private let mockData = MockData.mockPersonJsonData
private let mockRequest = MockRequest()
