@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileUploader call backs")
final class FileUploaderCallbacksTests {
    // MARK: SUCCESS

    @Test("test .uploadFileTask() Success")
    func uploadFileTaskSuccess() {
        let sut = createFileUploader()

        var didExecute = false
        sut.uploadFileTask(mockFileURL, with: mockRequest, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                #expect(Bool(true))
            case .failure:
                Issue.record()
            }
        }
        #expect(didExecute)
    }

    // MARK: Task Cancellation

    @Test("test .uploadFileTask() Can Cancel")
    func uploadFileTask_CanCancel() throws {
        let sut = createFileUploader()

        let task = sut.uploadFileTask(mockFileURL, with: mockRequest, progress: nil) { _ in }
        task?.cancel()
        let downloadTask = try #require(task as? MockURLSessionUploadTask)
        #expect(downloadTask.didCancel)
    }

    // MARK: ERROR - status code

    @Test("test .uploadFileTask() Fails When StatusCode Is Not 200")
    func uploadFileTask_FailsWhenStatusCodeIsNot2xx() {
        let sut = createFileUploader(
            urlSession: createMockURLSession(urlResponse: buildResponse(statusCode: 400))
        )

        var didExecute = false
        sut.uploadFileTask(mockFileURL, with: mockRequest, progress: nil) { result in
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

    // MARK: ERROR - url session

    @Test("test .uploadFileTask() Fails When urlSession Error Is Not Nil")
    func uploadFileTask_FailsWhenUrlSessionHasError() {
        let sut = createFileUploader(
            urlSession: createMockURLSession(error: HTTPError(statusCode: 400))
        )

        var didExecute = false
        sut.uploadFileTask(mockFileURL, with: mockRequest, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 400))))
            }
        }
        #expect(didExecute)
    }

    @Test("test .uploadFileTask() Fails When urlSession Error Is URLError")
    func uploadFileTask_FailsWhenUrlSessionHasURLError() {
        let sut = createFileUploader(
            urlSession: createMockURLSession(error: URLError(.notConnectedToInternet))
        )

        var didExecute = false
        sut.uploadFileTask(mockFileURL, with: mockRequest, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case let .failure(error):
                #expect(error == NetworkingError.urlError(URLError(.notConnectedToInternet)))
            }
        }
        #expect(didExecute)
    }

    // MARK: Traching with callback

    @Test("test .uploadFileTask() Download Progress Can Be Tracked")
    func uploadFileTask_progressCanBeTracked() {
        let urlSession = createMockURLSession()

        urlSession.progressToExecute = [.inProgress(percent: 50)]

        let sut = FileUploader(mockSession: urlSession)
        var didExecute = false
        var didTrackProgress = false

        _ = sut.uploadFileTask(mockFileURL, with: mockRequest, progress: { _ in
            didTrackProgress = true
        }, completion: { result in
            defer { didExecute = true }
            switch result {
            case .success: #expect(Bool(true))
            case .failure: Issue.record()
            }
        })
        #expect(didExecute)
        #expect(didTrackProgress)
    }

    @Test("test .uploadFileTask() Download Progress Tracking Happens Before Return")
    func uploadFileTask_progressTrackingHappensBeforeReturn() {
        let urlSession = createMockURLSession()

        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = FileUploader(mockSession: urlSession)
        var didTrackProgressBeforeReturn: Bool?

        _ = sut.uploadFileTask(mockFileURL, with: mockRequest, progress: { _ in
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

    @Test("test .uploadFileTask() Download Progress Tracks Correct Order")
    func uploadFileTask_progressTrackingHappensInCorrectOrder() {
        let urlSession = createMockURLSession()

        urlSession.progressToExecute = [
            .inProgress(percent: 30),
            .inProgress(percent: 60),
            .inProgress(percent: 90),
            .complete
        ]

        let sut = FileUploader(mockSession: urlSession)
        var capturedTracking = [Double]()

        _ = sut.uploadFileTask(
            mockFileURL,
            with: mockRequest,
            progress: { progress in
                capturedTracking.append(progress)
            },
            completion: { _ in }
        )

        #expect(capturedTracking.count == 4)
        #expect(capturedTracking == [0.3, 0.6, 0.9, 1.0])
    }

    // MARK: Traching with delegate

    @Test("test .uploadFileTask() Download Progress Can Be Tracked when Injecting SessionDelegat")
    func uploadFileTask_progressCanBeTrackedWhenInjectingSessionDelegate() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()

        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [.inProgress(percent: 50)]

        let sut = FileUploader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )

        var didExecute = false
        var didTrackProgress = false

        _ = sut.uploadFileTask(mockFileURL, with: mockRequest, progress: { _ in
            didTrackProgress = true
        }, completion: { result in
            defer { didExecute = true }
            switch result {
            case .success: #expect(Bool(true))
            case .failure: Issue.record()
            }
        })
        #expect(didExecute)
        #expect(didTrackProgress)
    }

    // MARK: Traching with interceptor

    @Test("test .uploadFileTask() Download Progress Can Be Tracked when Injecting DownloadTaskInterceptor")
    func uploadFileTask_progressCanBeTrackedWhenInjectingDownloadTaskInterceptor() {
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

        let sut = FileUploader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )

        var didExecute = false

        _ = sut.uploadFileTask(mockFileURL, with: mockRequest, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success: #expect(Bool(true))
            case .failure: Issue.record()
            }
        }
        #expect(didExecute)
        #expect(didTrackProgressFromInterceptor)
        #expect(uploadInterceptor.didCallDidSendBodyData)
    }
}

// MARK: - helpers

private func createFileUploader(
    urlSession: URLSessionProtocol = createMockURLSession()
) -> FileUploader {
    FileUploader(urlSession: urlSession)
}

private func createMockURLSession(
    data: Data? = Data(),
    urlResponse: URLResponse? = buildResponse(statusCode: 200),
    error: Error? = nil
) -> MockFileUploaderURLSession {
    MockFileUploaderURLSession(data: data, urlResponse: urlResponse, error: error)
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

extension FileUploader {
    /// Test-only initializer that mimics the production logic but uses MockFileDownloaderURLSession.
    fileprivate convenience init(
        mockSession: MockFileUploaderURLSession,
        validator: ResponseValidator = ResponseValidatorImpl(),
        requestDecoder: JSONDecoder = EZJSONDecoder()
    ) {
        let sessionDelegate = SessionDelegate()
        mockSession.sessionDelegate = sessionDelegate
        self.init(
            urlSession: mockSession,
            validator: validator,
            sessionDelegate: sessionDelegate
        )
    }
}

private let mockFileURL = URL(fileURLWithPath: "")
private let mockRequest = MockRequest()
