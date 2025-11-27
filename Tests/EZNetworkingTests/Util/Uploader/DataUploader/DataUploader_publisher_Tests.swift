import Combine
@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DataUploader publishers")
final class DataUploader_Publisher_Tests {
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: SUCCESS
    
    @Test("test .uploadDataPublisher() Success")
    func test_uploadDataPublisher_Success() {
        let sut = createDataUploader()
        
        var didExecute = false
        sut.uploadDataPublisher(mockData, with: mockRequest, progress: nil)
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
    
    @Test("test .uploadDataPublisher() Fails When Status Code Is Not 200")
    func test_uploadDataPublisher_FailsWhenStatusCodeIsNot200() {
        let sut = createDataUploader(
            urlSession: createMockURLSession(urlResponse: buildResponse(statusCode: 400))
        )
        
        var didExecute = false
        sut.uploadDataPublisher(mockData, with: mockRequest, progress: nil)
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
    
    @Test("test .uploadDataPublisher() Fails When URLSession Has Error")
    func test_uploadDataPublisher_FailsWhenUrlSessionHasError() {
        let sut = createDataUploader(
            urlSession: createMockURLSession(error: HTTPError(statusCode: 500))
        )
        
        var didExecute = false
        sut.uploadDataPublisher(mockData, with: mockRequest, progress: nil)
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
    
    @Test("test .uploadDataPublisher() Fails When URLSession Has URLError")
    func test_uploadDataPublisher_FailsWhenUrlSessionHasURLError() {
        let sut = createDataUploader(
            urlSession: createMockURLSession(error: URLError(.notConnectedToInternet))
        )
        
        var didExecute = false
        sut.uploadDataPublisher(mockData, with: mockRequest, progress: nil)
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
    
    @Test("test .uploadDataPublisher() Download Progress Can Be Tracked")
    func test_uploadDataPublisher_ProgressCanBeTracked() {
        let urlSession = createMockURLSession()
        
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = DataUploader(mockSession: urlSession)
        var didExecute = false
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
            didExecute = true
        }
        .store(in: &cancellables)
        
        #expect(didExecute)
        #expect(didTrackProgress)
    }
    
    @Test("test .uploadDataPublisher() Download Progress Tracking Happens Before Return")
    func test_uploadDataPublisher_ProgressTrackingHappensBeforeReturn() {
        let urlSession = createMockURLSession()
        
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
    
    @Test("test .uploadDataPublisher() Download Progress Tracks Correct Order")
    func test_uploadDataPublisher_ProgressTracksCorrectOrder() {
        let urlSession = createMockURLSession()
        
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
            case .finished: break
            }
        } receiveValue: { _ in }
            .store(in: &cancellables)
        
        #expect(capturedTracking.count == 4)
        #expect(capturedTracking == [0.3, 0.6, 0.9, 1.0])
    }
    
    // MARK: Tracking with delegate

    @Test("test .uploadDataPublisher() Download Progress Can Be Tracked when Injecting SessionDelegat")
    func test_uploadDataPublisher_ProgressCanBeTrackedWhenInjectingSessionDelegate() {
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
        
        var didExecute = false
        var didTrackProgress = false
        
        sut.uploadDataPublisher(mockData, with: mockRequest) { progress in
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

    @Test("test .uploadDataPublisher() Download Progress Can Be Tracked when Injecting DownloadTaskInterceptor")
    func test_uploadDataPublisher_DownloadFilePublisherTaskDownloadProgressCanBeTrackedWhenInjectingDownloadTaskInterceptor() {
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
            urlSession: urlSession,
            sessionDelegate: delegate
        )
        
        var didExecute = false
        
        sut.uploadDataPublisher(mockData, with: mockRequest, progress: nil)
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
