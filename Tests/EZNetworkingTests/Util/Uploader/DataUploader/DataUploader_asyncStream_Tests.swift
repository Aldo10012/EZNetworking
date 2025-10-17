import Combine
@testable import EZNetworking
import Foundation
import Testing


@Suite("Test DataUploadable async stream")
final class DataUploader_AsyncStream_Tests {
    
    // MARK: SUCCESS
    
    @Test("test .downloadFileStream() Success")
    func testDownloadFileStreamSuccess() async throws {
        let urlSession = createMockURLSession()
        let sut = DataUploader(
            urlSession: urlSession
        )
        
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

