@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DataUploader async/await methods")
final class DataUploader_asyncAwait_Tests {
    
    // MARK: - SUCCESS RESPONSE
    
    @Test("test .uploadData() with all valid inputs does not throw error")
    func test_upload_withValidInputs_doesNotThrowError() async throws {
        let sut = DataUploadaber(urlSession: createMockURLSession())
        await #expect(throws: Never.self) {
            try await sut.uploadData(MockData.mockPersonJsonData, with: MockRequest(), progress: nil)
        }
    }
    
    // MARK: - FAILURE RESPONSES
    
    
    
    // MARK: http status code error

    @Test("test .uploadData() throws when server responds with 3xx status code")
    func test_upload_withRedirectStatusCode_throwsError() async throws {
        let session = createMockURLSession(urlResponse: buildResponse(statusCode: 300))
        let sut = createDataUploader(urlSession: session)
        await #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 300))) {
            try await sut.uploadData(MockData.mockPersonJsonData, with: MockRequest(), progress: nil)
        }
    }
    
    @Test("test .uploadData() throws when server responds with 4xx status code")
    func test_upload_withClientErrorStatusCode_throwsError() async throws {
        let session = createMockURLSession(urlResponse: buildResponse(statusCode: 400))
        let sut = createDataUploader(urlSession: session)
        await #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 400))) {
            try await sut.uploadData(MockData.mockPersonJsonData, with: MockRequest(), progress: nil)
        }
    }
    
    @Test("test .uploadData() throws when server responds with 5xx status code")
    func test_upload_withServerErrorStatusCode_throwsError() async throws {
        let session = createMockURLSession(urlResponse: buildResponse(statusCode: 500))
        let sut = createDataUploader(urlSession: session)
        await #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 500))) {
            try await sut.uploadData(MockData.mockPersonJsonData, with: MockRequest(), progress: nil)
        }
    }
    
    // MARK: URLSession has error
    
    @Test("test .uploadData() throws when URLSession returns a 300 error")
    func test_upload_withHTTPError300_throwsError() async throws {
        let session = createMockURLSession(error: HTTPError(statusCode: 300))
        let sut = createDataUploader(urlSession: session)
        await #expect(throws: NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 300)))) {
            try await sut.uploadData(MockData.mockPersonJsonData, with: MockRequest(), progress: nil)
        }
    }

    @Test("test .uploadData() throws when URLSession returns a 400 error")
    func test_upload_withHTTPError400_throwsError() async throws {
        let session = createMockURLSession(error: HTTPError(statusCode: 400))
        let sut = createDataUploader(urlSession: session)
        await #expect(throws: NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 400)))) {
            try await sut.uploadData(MockData.mockPersonJsonData, with: MockRequest(), progress: nil)
        }
    }

    @Test("test .uploadData() throws when URLSession returns a 500 error")
    func test_upload_withHTTPError500_throwsError() async throws {
        let session = createMockURLSession(error: HTTPError(statusCode: 500))
        let sut = createDataUploader(urlSession: session)
        await #expect(throws: NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 500)))) {
            try await sut.uploadData(MockData.mockPersonJsonData, with: MockRequest(), progress: nil)
        }
    }
    
    @Test("test .uploadData() throws when URLSession returns a url error")
    func test_upload_withNetworkURLError_throwsError() async throws {
        let networkError = URLError(.notConnectedToInternet)
        let session = createMockURLSession(error: networkError)
        let sut = createDataUploader(urlSession: session)
        await #expect(throws: NetworkingError.urlError(URLError(.notConnectedToInternet))) {
            try await sut.uploadData(MockData.mockPersonJsonData, with: MockRequest(), progress: nil)
        }
    }
    
    // MARK: - Tracking
    
    
    @Test("test .uploadData() Download Progress Can Be Tracked")
    func test_upload_progress_canBeTracked() async throws {
        let urlSession = createMockURLSession()
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]
        
        let sut = DataUploadaber(mockSession: urlSession)
        var didTrackProgress = false
        
        do {
            _ = try await sut.uploadData(MockData.mockPersonJsonData, with: MockRequest(), progress: { _ in
                didTrackProgress = true
            })
            #expect(didTrackProgress)
        } catch {
            Issue.record()
        }
    }
}

// MARK: - helpers

private func createDataUploader(
    urlSession: URLSessionTaskProtocol = createMockURLSession()
) -> DataUploadaber {
    return DataUploadaber(urlSession: urlSession)
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

extension DataUploadaber {
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
