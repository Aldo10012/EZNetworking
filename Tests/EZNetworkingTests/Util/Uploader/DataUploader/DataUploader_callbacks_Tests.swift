@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DataUploader call backs")
final class DataUploaderCallbacksTests {
    // MARK: SUCCESS

    @Test("test .uploadDataTask() Success")
    func uploadDataTaskSuccess() async {
        let sut = createDataUploader()

        let expectation = Expectation()
        sut.uploadDataTask(mockData, with: mockRequest, progress: nil) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                #expect(Bool(true))
            case .failure:
                Issue.record()
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: ERROR - status code

    @Test("test .uploadDataTask() Fails When StatusCode Is Not 200")
    func uploadDataTask_FailsWhenStatusCodeIsNot2xx() async {
        let sut = createDataUploader(
            urlSession: createMockURLSession(urlResponse: buildResponse(statusCode: 400))
        )

        let expectation = Expectation()
        sut.uploadDataTask(mockData, with: mockRequest, progress: nil) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 400))))
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: ERROR - url session

    @Test("test .uploadDataTask() Fails When urlSession Error Is Not Nil")
    func uploadDataTask_FailsWhenUrlSessionHasError() async {
        let sut = createDataUploader(
            urlSession: createMockURLSession(error: NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 400))))
        )

        let expectation = Expectation()
        sut.uploadDataTask(mockData, with: mockRequest, progress: nil) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 400))))
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("test .uploadDataTask() Fails When urlSession Error Is URLError")
    func uploadDataTask_FailsWhenUrlSessionHasURLError() async {
        let sut = createDataUploader(
            urlSession: createMockURLSession(error: URLError(.notConnectedToInternet))
        )

        let expectation = Expectation()
        sut.uploadDataTask(mockData, with: mockRequest, progress: nil) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.requestFailed(reason: .urlError(underlying: URLError(.notConnectedToInternet))))
            }
        }
        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: Traching with callback

    @Test("test .uploadDataTask() Download Progress Can Be Tracked")
    func uploadDataTask_progressCanBeTracked() async {
        let urlSession = createMockURLSession()

        urlSession.progressToExecute = [.inProgress(percent: 50)]

        let sut = DataUploader(mockSession: urlSession)
        let expectation = Expectation()
        var didTrackProgress = false

        _ = sut.uploadDataTask(mockData, with: mockRequest, progress: { _ in
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

    @Test("test .uploadDataTask() Download Progress Tracking Happens Before Return")
    func uploadDataTask_progressTrackingHappensBeforeReturn() async {
        let urlSession = createMockURLSession()
        let expectation = Expectation()

        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = DataUploader(mockSession: urlSession)
        var didTrackProgressBeforeReturn: Bool?

        _ = sut.uploadDataTask(mockData, with: mockRequest, progress: { _ in
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

    @Test("test .uploadDataTask() Download Progress Tracks Correct Order")
    func uploadDataTask_progressTrackingHappensInCorrectOrder() async {
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

        _ = sut.uploadDataTask(
            mockData,
            with: mockRequest,
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

    @Test("test .uploadDataTask() Download Progress Can Be Tracked when Injecting SessionDelegat")
    func uploadDataTask_progressCanBeTrackedWhenInjectingSessionDelegate() async {
        let urlSession = createMockURLSession()

        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [.inProgress(percent: 50)]

        let sut = DataUploader(
            session: MockSession(urlSession: urlSession, delegate: delegate)
        )

        let expectation = Expectation()
        var didTrackProgress = false

        _ = sut.uploadDataTask(mockData, with: mockRequest, progress: { _ in
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

    @Test("test .uploadDataTask() Download Progress Can Not Be Tracked when Injecting DownloadTaskInterceptor")
    func uploadDataTask_progressCanNotBeTrackedWhenInjectingDownloadTaskInterceptor() async {
        let urlSession = createMockURLSession()

        var didTrackProgressFromInterceptor = false

        let uploadInterceptor = MockUploadTaskInterceptor { _ in
            didTrackProgressFromInterceptor = true
        }
        let delegate = SessionDelegate(
            uploadTaskInterceptor: uploadInterceptor
        )
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [.inProgress(percent: 50)]

        let sut = DataUploader(
            session: MockSession(urlSession: urlSession, delegate: delegate)
        )

        let expectation = Expectation()

        _ = sut.uploadDataTask(mockData, with: mockRequest, progress: nil) { result in
            defer { expectation.fulfill() }
            switch result {
            case .success: #expect(Bool(true))
            case .failure: Issue.record()
            }
        }
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
        validator: ResponseValidator = DefaultResponseValidator(),
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
