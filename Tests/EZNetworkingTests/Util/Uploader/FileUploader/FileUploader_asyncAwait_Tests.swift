@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileUploader async/await methods")
final class FileUploaderAsyncAwaitTests {
    // MARK: - SUCCESS RESPONSE

    @Test("test .uploadFile() with all valid inputs does not throw error")
    func uploadFile_withValidInputs_doesNotThrowError() async throws {
        let sut = FileUploader(urlSession: createMockURLSession())
        await #expect(throws: Never.self) {
            try await sut.uploadFile(mockFileURL, with: mockRequest, progress: nil)
        }
    }

    // MARK: - FAILURE RESPONSES

    // MARK: http status code error

    @Test("test .uploadFile() throws when server responds with 3xx status code")
    func uploadFile_withRedirectStatusCode_throwsError() async throws {
        let session = createMockURLSession(urlResponse: buildResponse(statusCode: 300))
        let sut = createFileUploader(urlSession: session)
        await #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 300))) {
            try await sut.uploadFile(mockFileURL, with: mockRequest, progress: nil)
        }
    }

    @Test("test .uploadFile() throws when server responds with 4xx status code")
    func uploadFile_withClientErrorStatusCode_throwsError() async throws {
        let session = createMockURLSession(urlResponse: buildResponse(statusCode: 400))
        let sut = createFileUploader(urlSession: session)
        await #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 400))) {
            try await sut.uploadFile(mockFileURL, with: mockRequest, progress: nil)
        }
    }

    @Test("test .uploadFile() throws when server responds with 5xx status code")
    func uploadFile_withServerErrorStatusCode_throwsError() async throws {
        let session = createMockURLSession(urlResponse: buildResponse(statusCode: 500))
        let sut = createFileUploader(urlSession: session)
        await #expect(throws: NetworkingError.httpError(HTTPError(statusCode: 500))) {
            try await sut.uploadFile(mockFileURL, with: mockRequest, progress: nil)
        }
    }

    // MARK: URLSession has error

    @Test("test .uploadFile() throws when URLSession returns a 300 error")
    func uploadFile_withHTTPError300_throwsError() async throws {
        let session = createMockURLSession(error: HTTPError(statusCode: 300))
        let sut = createFileUploader(urlSession: session)
        await #expect(throws: NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 300)))) {
            try await sut.uploadFile(mockFileURL, with: mockRequest, progress: nil)
        }
    }

    @Test("test .uploadFile() throws when URLSession returns a 400 error")
    func uploadFile_withHTTPError400_throwsError() async throws {
        let session = createMockURLSession(error: HTTPError(statusCode: 400))
        let sut = createFileUploader(urlSession: session)
        await #expect(throws: NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 400)))) {
            try await sut.uploadFile(mockFileURL, with: mockRequest, progress: nil)
        }
    }

    @Test("test .uploadFile() throws when URLSession returns a 500 error")
    func uploadFile_withHTTPError500_throwsError() async throws {
        let session = createMockURLSession(error: HTTPError(statusCode: 500))
        let sut = createFileUploader(urlSession: session)
        await #expect(throws: NetworkingError.internalError(.requestFailed(HTTPError(statusCode: 500)))) {
            try await sut.uploadFile(mockFileURL, with: mockRequest, progress: nil)
        }
    }

    @Test("test .uploadFile() throws when URLSession returns a url error")
    func uploadFile_withNetworkURLError_throwsError() async throws {
        let networkError = URLError(.notConnectedToInternet)
        let session = createMockURLSession(error: networkError)
        let sut = createFileUploader(urlSession: session)
        await #expect(throws: NetworkingError.urlError(URLError(.notConnectedToInternet))) {
            try await sut.uploadFile(mockFileURL, with: mockRequest, progress: nil)
        }
    }

    // MARK: - Tracking

    @Test("test .uploadFile() Download Progress Can Be Tracked")
    func uploadFile_progress_canBeTracked() async throws {
        let urlSession = createMockURLSession()
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = FileUploader(mockSession: urlSession)
        var didTrackProgress = false

        do {
            _ = try await sut.uploadFile(mockFileURL, with: mockRequest, progress: { _ in
                didTrackProgress = true
            })
            #expect(didTrackProgress)
        } catch {
            Issue.record()
        }
    }

    @Test("test .uploadFile() Progress Tracking Happens Before Return")
    func uploadFile_progressTrackingHappensBeforeReturn() async throws {
        let urlSession = createMockURLSession()
        urlSession.progressToExecute = [
            .inProgress(percent: 50)
        ]

        let sut = FileUploader(mockSession: urlSession)
        var progressAndReturnList = [String]()

        do {
            _ = try await sut.uploadFile(mockFileURL, with: mockRequest, progress: { _ in
                progressAndReturnList.append("did track progress")
            })
            progressAndReturnList.append("did return")

            #expect(progressAndReturnList.count == 2)
            #expect(progressAndReturnList[0] == "did track progress")
            #expect(progressAndReturnList[1] == "did return")
        } catch {
            Issue.record()
        }
    }

    @Test("test .uploadFile() Progress Tracking Order")
    func uploadFile_progressTrackingOrder() async throws {
        let urlSession = createMockURLSession()
        urlSession.progressToExecute = [
            .inProgress(percent: 30),
            .inProgress(percent: 60),
            .inProgress(percent: 90),
            .complete
        ]

        let sut = FileUploader(mockSession: urlSession)
        var capturedTracking = [Double]()

        do {
            _ = try await sut.uploadFile(mockFileURL, with: mockRequest, progress: { value in
                capturedTracking.append(value)
            })
            #expect(capturedTracking.count == 4)
            #expect(capturedTracking == [0.3, 0.6, 0.9, 1.0])
        } catch {
            Issue.record()
        }
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
