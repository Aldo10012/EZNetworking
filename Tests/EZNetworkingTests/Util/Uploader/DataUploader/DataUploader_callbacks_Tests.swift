@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DataUploader call backs")
final class DataUploader_Callbacks_Tests {
    
    // MARK: SUCCESS
    
    @Test("test .uploadFileTask() Success")
    func testUploadFileTaskSuccess() {
        let sut = createDataUploader()
        
        var didExecute = false
        sut.uploadDataTask(mockData, with: mockRequest, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                #expect(true)
            case .failure:
                Issue.record()
            }
        }
        #expect(didExecute)
    }
    
    // MARK: Task Cancellation
    
    @Test("test .uploadFileTask() Can Cancel")
    func test_uploadFileTask_CanCancel() throws {
        let sut = createDataUploader()
        
        let task = sut.uploadDataTask(mockData, with: mockRequest, progress: nil) { _ in }
        task?.cancel()
        let downloadTask = try #require(task as? MockURLSessionUploadTask)
        #expect(downloadTask.didCancel)
    }
    
    // MARK: ERROR - status code
    
    @Test("test .uploadFileTask() Fails When StatusCode Is Not 200")
    func test_uploadFileTask_FailsWhenStatusCodeIsNot2xx() {
        let sut = createDataUploader(
            urlSession: createMockURLSession(urlResponse: buildResponse(statusCode: 400))
        )
        
        var didExecute = false
        sut.uploadDataTask(mockData, with: mockRequest, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.httpError(HTTPError(statusCode: 400)))
            }
        }
        #expect(didExecute)
    }
    
    // MARK: ERROR - url session
    
    @Test("test .uploadFileTask() Fails When urlSession Error Is Not Nil")
    func test_uploadFileTask_FailsWhenUrlSessionHasError() {
        let sut = createDataUploader(
            urlSession: createMockURLSession(error: HTTPError(statusCode: 400))
        )
        
        var didExecute = false
        sut.uploadDataTask(mockData, with: mockRequest, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 400))))
            }
        }
        #expect(didExecute)
    }
    
    @Test("test .uploadFileTask() Fails When urlSession Error Is URLError")
    func test_uploadFileTask_FailsWhenUrlSessionHasURLError() {
        let sut = createDataUploader(
            urlSession: createMockURLSession(error: URLError(.notConnectedToInternet))
        )
        
        var didExecute = false
        sut.uploadDataTask(mockData, with: mockRequest, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success:
                Issue.record()
            case .failure(let error):
                #expect(error == NetworkingError.urlError(URLError(.notConnectedToInternet)))
            }
        }
        #expect(didExecute)
    }
    
    // MARK: Traching with callback
    
    @Test("test .uploadFileTask() Download Progress Can Be Tracked")
    func test_uploadFileTask_progressCanBeTracked() {
        let urlSession = createMockURLSession()
        
        urlSession.progressToExecute = [.inProgress(percent: 50)]
        
        let sut = DataUploader(mockSession: urlSession)
        var didExecute = false
        var didTrackProgress = false
        
        _ = sut.uploadDataTask(mockData, with: mockRequest, progress: { progress in
            didTrackProgress = true
        }) { result in
            defer { didExecute = true }
            switch result {
            case .success: #expect(true)
            case .failure: Issue.record()
            }
        }
        #expect(didExecute)
        #expect(didTrackProgress)
    }
    
    @Test("test .uploadFileTask() Download Progress Tracking Happens Before Return")
    func test_uploadFileTask_progressTrackingHappensBeforeReturn() {
        let urlSession = createMockURLSession()
        
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = DataUploader(mockSession: urlSession)
        var didTrackProgressBeforeReturn: Bool? = nil
        
        _ = sut.uploadDataTask(mockData, with: mockRequest, progress: { progress in
            if didTrackProgressBeforeReturn == nil {
                didTrackProgressBeforeReturn = true
            }
        }) { result in
            switch result {
            case .success:
                if didTrackProgressBeforeReturn == nil {
                    didTrackProgressBeforeReturn = true
                }
            case .failure:
                Issue.record()
            }
        }
        #expect(didTrackProgressBeforeReturn == true)
    }
    
    @Test("test .uploadFileTask() Download Progress Tracks Correct Order")
    func test_uploadFileTask_progressTrackingHappensInCorrectOrder() {
        let urlSession = createMockURLSession()
        
        urlSession.progressToExecute = [
            .inProgress(percent: 30),
            .inProgress(percent: 60),
            .inProgress(percent: 90),
            .complete
        ]
        
        let sut = DataUploader(mockSession: urlSession)
        var capturedTracking = [Double]()
        
        _ = sut.uploadDataTask(mockData, with: mockRequest, progress: { progress in
                capturedTracking.append(progress)
            },
            completion: { _ in }
        )
        
        #expect(capturedTracking.count == 4)
        #expect(capturedTracking == [0.3, 0.6, 0.9, 1.0])
    }
    
    // MARK: Traching with delegate
    
    @Test("test .uploadFileTask() Download Progress Can Be Tracked when Injecting SessionDelegat")
    func test_uploadFileTask_progressCanBeTrackedWhenInjectingSessionDelegate() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = createMockURLSession()
        
        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [.inProgress(percent: 50)]
        
        let sut = DataUploader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )
        
        var didExecute = false
        var didTrackProgress = false
        
        _ = sut.uploadDataTask(mockData, with: mockRequest, progress: { progress in
            didTrackProgress = true
        }) { result in
            defer { didExecute = true }
            switch result {
            case .success: #expect(true)
            case .failure: Issue.record()
            }
        }
        #expect(didExecute)
        #expect(didTrackProgress)
    }
    
    // MARK: Traching with interceptor
    
    @Test("test .uploadFileTask() Download Progress Can Be Tracked when Injecting DownloadTaskInterceptor")
    func test_uploadFileTask_progressCanBeTrackedWhenInjectingDownloadTaskInterceptor() {
        let urlSession = createMockURLSession()
        
        var didTrackProgressFromInterceptor = false

        let uploadInterceptor = DataUploader_MockUploadTaskInterceptor { _ in
            didTrackProgressFromInterceptor = true
        }
        let delegate = SessionDelegate(
            uploadTaskInterceptor: uploadInterceptor
        )
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [.inProgress(percent: 50)]
        
        let sut = DataUploader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )
        
        var didExecute = false
        
        _ = sut.uploadDataTask(mockData, with: mockRequest, progress: nil) { result in
            defer { didExecute = true }
            switch result {
            case .success: #expect(true)
            case .failure: Issue.record()
            }
        }
        #expect(didExecute)
        #expect(didTrackProgressFromInterceptor)
        #expect(uploadInterceptor.didCallDidSendBodyData)
    }
}


// MARK: - helpers

private func createDataUploader(
    urlSession: URLSessionTaskProtocol = createMockURLSession()
) -> DataUploader {
    return DataUploader(urlSession: urlSession)
}

private func createMockURLSession(
    data: Data? = Data(),
    urlResponse: URLResponse? = buildResponse(statusCode: 200),
    error: Error? = nil
) -> MockDataUploaderURLSession {
    MockDataUploaderURLSession(data: data, urlResponse: urlResponse, error: error)
}

private func buildResponse(statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(url: URL(string: "https://example.com")!,
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil)!
}

private struct MockRequest: Request {
    var httpMethod: HTTPMethod { .GET }
    var baseUrlString: String { "https://www.example.com" }
    var parameters: [HTTPParameter]? { nil }
    var headers: [HTTPHeader]? { nil }
    var body: HTTPBody? { nil }
}

private extension DataUploader {
    /// Test-only initializer that mimics the production logic but uses MockFileDownloaderURLSession.
    convenience init(
        mockSession: MockDataUploaderURLSession,
        validator: ResponseValidator = ResponseValidatorImpl(),
        requestDecoder: RequestDecodable = RequestDecoder()
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

private let mockData = MockData.mockPersonJsonData
private let mockRequest = MockRequest()
