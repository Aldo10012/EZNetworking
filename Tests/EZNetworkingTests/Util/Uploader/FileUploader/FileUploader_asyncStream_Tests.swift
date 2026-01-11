import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileUploadable async stream")
final class FileUploader_AsyncStream_Tests {
    
    // MARK: SUCCESS
    
    @Test("test .uploadFileStream() Success")
    func test_uploadFileStream_streamSuccess() async throws {
        let sut = FileUploader(urlSession: createMockURLSession())
        
        var events: [UploadStreamEvent] = []
        for await event in sut.uploadFileStream(mockFileURL, with: mockRequest) {
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

    @Test("test .uploadFileStream() Fails When StatusCode Is not 200")
    func test_uploadFileStream_withRedirectStatusCode() async throws {
        let sut = FileUploader(
            urlSession: createMockURLSession(
                urlResponse: buildResponse(statusCode: 400)
            )
        )
        var events: [UploadStreamEvent] = []
        for await event in sut.uploadFileStream(mockFileURL, with: mockRequest) {
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
    
    @Test("test .uploadFileStream() Fails when URLSession has error")
    func test_uploadFileStream_whenURLSessionHasError_throwsError() async throws {
        let sut = FileUploader(
            urlSession: createMockURLSession(
                error: HTTPError(statusCode: 500)
            )
        )
        var events: [UploadStreamEvent] = []
        for await event in sut.uploadFileStream(mockFileURL, with: mockRequest) {
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
    
    @Test("test .uploadFileStream() Fails when URLSession has URLError")
    func test_uploadFileStream_whenURLSessionHasURLError_throwsError() async throws {
        let sut = FileUploader(
            urlSession: createMockURLSession(
                error: URLError(.notConnectedToInternet)
            )
        )
        var events: [UploadStreamEvent] = []
        for await event in sut.uploadFileStream(mockFileURL, with: mockRequest) {
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
    
    @Test("test .uploadFileStream() Upload Progress Can Be Tracked")
    func test_uploadFileStream_progressCanBeTracked() async throws {
        let urlSession = createMockURLSession()
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = FileUploader(mockSession: urlSession)
        var didTrackProgress = false
        
        for await event in sut.uploadFileStream(mockFileURL, with: mockRequest) {
            switch event {
            case .progress:
                didTrackProgress = true
            case .success: break
            case .failure: Issue.record()
            }
        }
        #expect(didTrackProgress)
    }
    
    @Test("test .uploadFileStream() Upload Progress Tracking Happens Before Final Result")
    func test_uploadFileStream_progressTrackingHappensBeforeFinalResult() async throws {
        let urlSession = createMockURLSession()
        
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = FileUploader(mockSession: urlSession)
        var progressAndReturnList = [String]()
        
        for await event in sut.uploadFileStream(mockFileURL, with: mockRequest) {
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
    
    @Test("test .uploadFileStream() Upload Progress Tracking Order")
    func test_uploadFileStream_progressTrackingOrder() async throws {
        let urlSession = createMockURLSession()
        
        urlSession.progressToExecute = [
            .inProgress(percent: 30),
            .inProgress(percent: 60),
            .inProgress(percent: 90),
            .complete
        ]
        
        let sut = FileUploader(mockSession: urlSession)
        var progressValues: [Double] = []
        var didReceiveSuccess = false
        
        for await event in sut.uploadFileStream(mockFileURL, with: mockRequest) {
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
    
    @Test("test .uploadFileStream() Upload Progress Can Be Tracked when Injecting SessionDelegat")
    func test_uploadFileStream_progressCanBeTrackedWhenInjectingSessionDelegate() async throws {
        let urlSession = createMockURLSession()
        
        let delegate = SessionDelegate()
        urlSession.sessionDelegate = delegate
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = FileUploader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )
        
        var didTrackProgress = false
        
        for await event in sut.uploadFileStream(mockFileURL, with: mockRequest) {
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
    
    @Test("test .uploadFileStream() Upload Progress Can Be Tracked when Injecting DownloadTaskInterceptor")
    func test_uploadFileStream_progressCanBeTrackedWhenInjectingDownloadTaskInterceptor() async throws {
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
        
        let sut = FileUploader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )
        
        for await event in sut.uploadFileStream(mockFileURL, with: mockRequest) {
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

private func createFileUploader(
    urlSession: URLSessionTaskProtocol = createMockURLSession()
) -> FileUploader {
    return FileUploader(urlSession: urlSession)
}

private func createMockURLSession(
    data: Data? = Data(),
    urlResponse: URLResponse? = buildResponse(statusCode: 200),
    error: Error? = nil
) -> MockFileUploaderURLSession {
    MockFileUploaderURLSession(data: data, urlResponse: urlResponse, error: error)
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

private extension FileUploader {
    /// Test-only initializer that mimics the production logic but uses MockFileDownloaderURLSession.
    convenience init(
        mockSession: MockFileUploaderURLSession,
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

private let mockFileURL = URL(fileURLWithPath: "")
private let mockRequest = MockRequest()
