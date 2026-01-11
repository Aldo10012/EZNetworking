import Combine
@testable import EZNetworking
import Foundation
import Testing


@Suite("Test DataUploadable async stream")
final class DataUploader_AsyncStream_Tests {
    
    // MARK: SUCCESS
    
    @Test("test .uploadDataStream() Success")
    func test_uploadDataStream_streamSuccess() async throws {
        let sut = DataUploader(urlSession: createMockURLSession())
        
        var events: [UploadStreamEvent] = []
        for await event in sut.uploadDataStream(mockData, with: mockRequest) {
            events.append(event)
        }
        
        #expect(events.count == 1)
        switch events[0] {
        case .success:
            #expect(true)
        default:
            Issue.record()
        }
    }
    
    // MARK: ERROR - status code

    @Test("test .uploadDataStream() Fails When StatusCode Is not 200")
    func test_uploadDataStream_withRedirectStatusCode() async throws {
        let sut = DataUploader(
            urlSession: createMockURLSession(
                urlResponse: buildResponse(statusCode: 400)
            )
        )
        var events: [UploadStreamEvent] = []
        for await event in sut.uploadDataStream(mockData, with: mockRequest) {
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
    
    // MARK: Error - url has error
    
    @Test("test .uploadDataStream() Fails when URLSession has error")
    func test_uploadDataStream_whenURLSessionHasError_throwsError() async throws {
        let sut = DataUploader(
            urlSession: createMockURLSession(
                error: HTTPError(statusCode: 500)
            )
        )
        var events: [UploadStreamEvent] = []
        for await event in sut.uploadDataStream(mockData, with: mockRequest) {
            events.append(event)
        }
        
        #expect(events.count == 1)
        switch events[0] {
        case .failure(let error):
            #expect(error == NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 500))))
        default:
            Issue.record()
        }
    }
    
    @Test("test .uploadDataStream() Fails when URLSession has URLError")
    func test_uploadDataStream_whenURLSessionHasURLError_throwsError() async throws {
        let sut = DataUploader(
            urlSession: createMockURLSession(
                error: URLError(.notConnectedToInternet)
            )
        )
        var events: [UploadStreamEvent] = []
        for await event in sut.uploadDataStream(mockData, with: mockRequest) {
            events.append(event)
        }
        
        #expect(events.count == 1)
        switch events[0] {
        case .failure(let error):
            #expect(error == NetworkingError.urlError(URLError(.notConnectedToInternet)))
        default:
            Issue.record()
        }
    }
    
    // MARK: - Tracking
    
    @Test("test .uploadDataStream() Upload Progress Can Be Tracked")
    func test_uploadDataStream_progressCanBeTracked() async throws {
        let urlSession = createMockURLSession()
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = DataUploader(mockSession: urlSession)
        var didTrackProgress = false
        
        for await event in sut.uploadDataStream(mockData, with: mockRequest) {
            switch event {
            case .progress:
                didTrackProgress = true
            case .success: break
            case .failure: Issue.record()
            }
        }
        #expect(didTrackProgress)
    }
    
    @Test("test .uploadDataStream() Upload Progress Tracking Happens Before Final Result")
    func test_uploadDataStream_progressTrackingHappensBeforeFinalResult() async throws {
        let urlSession = createMockURLSession()
        
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = DataUploader(mockSession: urlSession)
        var progressAndReturnList = [String]()
        
        for await event in sut.uploadDataStream(mockData, with: mockRequest) {
            switch event {
            case .progress:
                progressAndReturnList.append("did track progress")
            case .success:
                progressAndReturnList.append("did return")
            default:
                Issue.record()
            }
        }
        
        #expect(progressAndReturnList.count == 2)
        #expect(progressAndReturnList[0] == "did track progress")
        #expect(progressAndReturnList[1] == "did return")
    }
    
    @Test("test .uploadDataStream() Upload Progress Tracking Order")
    func test_uploadDataStream_progressTrackingOrder() async throws {
        let urlSession = createMockURLSession()
        
        urlSession.progressToExecute = [
            .inProgress(percent: 30),
            .inProgress(percent: 60),
            .inProgress(percent: 90),
            .complete
        ]
        
        let sut = DataUploader(mockSession: urlSession)
        var progressValues: [Double] = []
        var didReceiveSuccess = false
        
        for await event in sut.uploadDataStream(mockData, with: mockRequest) {
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
    
    @Test("test .uploadDataStream() Upload Progress Can Be Tracked when Injecting SessionDelegat")
    func test_uploadDataStream_progressCanBeTrackedWhenInjectingSessionDelegate() async throws {
        let urlSession = createMockURLSession()
        
        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = DataUploader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )
        
        var didTrackProgress = false
        
        for await event in sut.uploadDataStream(mockData, with: mockRequest) {
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
    
    @Test("test .uploadDataStream() Upload Progress Can Be Tracked when Injecting DownloadTaskInterceptor")
    func test_uploadDataStream_progressCanBeTrackedWhenInjectingDownloadTaskInterceptor() async throws {
        let urlSession = createMockURLSession()

        var didTrackProgressStreamEvent = false
        var didTrackProgressFromInterceptorClosure = false
        let uploadInterceptor = MockUploadTaskInterceptor(progress: { _ in
            didTrackProgressFromInterceptorClosure = true
        })
        let delegate = SessionDelegate(
            uploadTaskInterceptor: uploadInterceptor
        )
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = DataUploader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )
        
        
        for await event in sut.uploadDataStream(mockData, with: mockRequest) {
            switch event {
            case .progress: didTrackProgressStreamEvent = true
            case .success: break
            case .failure: Issue.record()
            }
        }
        
        #expect(uploadInterceptor.didCallDidSendBodyData)
        #expect(didTrackProgressStreamEvent)
        #expect(didTrackProgressFromInterceptorClosure == false) // closure inside of interceptor gets overwritten
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
    var baseUrl: String { "https://www.example.com" }
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

