import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileUploader publishers")
final class FileUploader_Publisher_Tests {
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: SUCCESS
    
    @Test("test .uploadFilePublisher() Success")
    func test_uploadFilePublisher_Success() {
        let sut = createFileUploader()
        
        var didExecute = false
        sut.uploadFilePublisher(mockFileURL, with: mockRequest, progress: nil)
            .sink { completion in
                switch completion {
                case .failure: Issue.record()
                case .finished: break
                }
            } receiveValue: { _ in
                #expect(true)
                didExecute = true
            }
            .store(in: &cancellables)
        
        #expect(didExecute)
    }
    
    // MARK: ERROR - status code
    
    @Test("test .uploadFilePublisher() Fails When Status Code Is Not 200")
    func test_uploadFilePublisher_FailsWhenStatusCodeIsNot200() {
        let sut = createFileUploader(
            urlSession: createMockURLSession(urlResponse: buildResponse(statusCode: 400))
        )
        
        var didExecute = false
        sut.uploadFilePublisher(mockFileURL, with: mockRequest, progress: nil)
            .sink { completion in
                switch completion {
                case .failure(let error):
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
    
    // MARK: ERROR - url session
    
    @Test("test .uploadFilePublisher() Fails When URLSession Has Error")
    func test_uploadFilePublisher_FailsWhenUrlSessionHasError() {
        let sut = createFileUploader(
            urlSession: createMockURLSession(error: HTTPError(statusCode: 500))
        )
        
        var didExecute = false
        sut.uploadFilePublisher(mockFileURL, with: mockRequest, progress: nil)
            .sink { completion in
                switch completion {
                case .failure(let error):
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
    
    @Test("test .uploadFilePublisher() Fails When URLSession Has URLError")
    func test_uploadFilePublisher_FailsWhenUrlSessionHasURLError() {
        let sut = createFileUploader(
            urlSession: createMockURLSession(error: URLError(.notConnectedToInternet))
        )
        
        var didExecute = false
        sut.uploadFilePublisher(mockFileURL, with: mockRequest, progress: nil)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    #expect(error == NetworkingError.urlError(URLError(.notConnectedToInternet)))
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
    
    @Test("test .uploadFilePublisher() Download Progress Can Be Tracked")
    func test_uploadFilePublisher_ProgressCanBeTracked() {
        let urlSession = createMockURLSession()
        
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = FileUploader(mockSession: urlSession)
        var didExecute = false
        var didTrackProgress = false
        
        sut.uploadFilePublisher(mockFileURL, with: mockRequest) { _ in
            didTrackProgress = true
        }
        .sink { completion in
            switch completion {
            case .failure: Issue.record()
            case .finished: break
            }
        } receiveValue: { _ in
            didExecute = true
        }
        .store(in: &cancellables)
        
        #expect(didExecute)
        #expect(didTrackProgress)
    }
    
    @Test("test .uploadFilePublisher() Download Progress Tracking Happens Before Return")
    func test_uploadFilePublisher_ProgressTrackingHappensBeforeReturn() {
        let urlSession = createMockURLSession()
        
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = FileUploader(mockSession: urlSession)
        var progressAndReturnList = [String]()
        
        sut.uploadFilePublisher(mockFileURL, with: mockRequest) { _ in
            progressAndReturnList.append("did track progress")
        }
        .sink { completion in
            switch completion {
            case .failure: Issue.record()
            case .finished: break
            }
        } receiveValue: { _ in
            progressAndReturnList.append("did return")
        }
        .store(in: &cancellables)
        
        #expect(progressAndReturnList.count == 2)
        #expect(progressAndReturnList[0] == "did track progress")
        #expect(progressAndReturnList[1] == "did return")
    }
    
    @Test("test .uploadFilePublisher() Download Progress Tracks Correct Order")
    func test_uploadFilePublisher_ProgressTracksCorrectOrder() {
        let urlSession = createMockURLSession()
        
        urlSession.progressToExecute = [
            .inProgress(percent: 30),
            .inProgress(percent: 60),
            .inProgress(percent: 90),
            .complete
        ]
        
        let sut = FileUploader(mockSession: urlSession)
        var capturedTracking = [Double]()
        
        sut.uploadFilePublisher(mockFileURL, with: mockRequest) { progress in
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

    @Test("test .uploadFilePublisher() Download Progress Can Be Tracked when Injecting SessionDelegat")
    func test_uploadFilePublisher_ProgressCanBeTrackedWhenInjectingSessionDelegate() {
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
        
        var didExecute = false
        var didTrackProgress = false
        
        sut.uploadFilePublisher(mockFileURL, with: mockRequest) { progress in
            didTrackProgress = true
        }
        .sink { completion in
            switch completion {
            case .failure: Issue.record()
            case .finished: break
            }
        } receiveValue: { _ in
            didExecute = true
        }
        .store(in: &cancellables)
        
        #expect(didExecute)
        #expect(didTrackProgress)
    }
    
    // MARK: Tracking with Interceptor

    @Test("test .uploadFilePublisher() Download Progress Can Be Tracked when Injecting DownloadTaskInterceptor")
    func test_uploadFilePublisher_DownloadFilePublisherTaskDownloadProgressCanBeTrackedWhenInjectingDownloadTaskInterceptor() {
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
        
        let sut = FileUploader(
            urlSession: urlSession,
            sessionDelegate: delegate
        )
        
        var didExecute = false
        
        sut.uploadFilePublisher(mockFileURL, with: mockRequest, progress: nil)
            .sink { completion in
                switch completion {
                case .failure: Issue.record()
                case .finished: break
                }
            } receiveValue: { _ in
                didExecute = true
            }
            .store(in: &cancellables)
        
        #expect(didExecute)
        #expect(didTrackProgressFromInterceptor)
        #expect(uploadInterceptor.didCallDidSendBodyData)
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
