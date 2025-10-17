@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DataUploader async/await methods")
final class DataUploader_asyncAwait_Tests {
    
    // MARK: - SUCCESS RESPONSE

    @Test("test perform(request:_, decodeTo:_) with all valid inputs does not throw error")
    func perform_withValidInputs_doesNotThrowError() async throws {
        let sut = DataUploadaber(urlSession: createMockURLSession())
        await #expect(throws: Never.self) {
            try await sut.uploadData(MockData.mockPersonJsonData, with: MockRequest(), progress: nil)
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
    data: Data? = MockData.mockPersonJsonData,
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

private struct MockRequestWithNilBuild: Request {
    var httpMethod: HTTPMethod { .GET }
    var baseUrlString: String { "https://www.example.com" }
    var parameters: [HTTPParameter]? { nil }
    var headers: [HTTPHeader]? { nil }
    var body: HTTPBody? { nil }
    var urlRequest: URLRequest? { nil }
}
