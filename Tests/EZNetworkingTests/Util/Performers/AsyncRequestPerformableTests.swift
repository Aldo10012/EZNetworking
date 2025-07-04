@testable import EZNetworking
import Foundation
import Testing

@Suite("Test AsyncRequestPerformable")
final class AsyncRequestPerformableTests {
    
    // MARK: Unit test for perform request with Async Await and Request protocol and return Decodable

    @Test("test PerformAsync Success")
    func test_PerformAsync_Success() async throws {
        let sut = createAsyncRequestPerformer()
        let person = try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        #expect(person.name == "John")
        #expect(person.age == 30)
    }
    
    @Test("test PerformAsync StatusCode300 Success")
    func test_PerformAsync_StatusCode300_Success() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        await #expect(throws: NetworkingError.redirect(.multipleChoices, [:])) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }
    
    @Test("test PerformAsync WhenStatusCodeIsNot200 Fails")
    func test_PerformAsync_WhenStatusCodeIsNot200_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        await #expect(throws: NetworkingError.httpClientError(.badRequest, [:])) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }
    
    @Test("test PerformAsync WhenThereIsError Fails")
    func test_PerformAsync_WhenThereIsError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpClientError(.badRequest, [:]))
        )
        await #expect(throws: NetworkingError.httpClientError(.badRequest, [:])) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }
    
    @Test("test PerformAsync WhenThereIsHTTPError Fails")
    func test_PerformAsync_WhenThereIsHTTPError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpClientError(.forbidden, [:]))
        )
        await #expect(throws: NetworkingError.httpClientError(.forbidden, [:])) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }
    
    @Test("test PerformAsync WhenThereIsURLError Fails")
    func test_PerformAsync_WhenThereIsURLError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: URLError(.networkConnectionLost))
        )
        await #expect(throws: NetworkingError.urlError(URLError(.networkConnectionLost))) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }
    
    @Test("test PerformAsync WhenDataCannotBeDecodedToType Fails")
    func test_PerformAsync_WhenDataCannotBeDecodedToType_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(data: MockData.invalidMockPersonJsonData)
        )
        await #expect(throws: NetworkingError.internalError(.couldNotParse)) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }
    
    @Test("test PerformAsync WhenDataIsNil Fails")
    func test_PerformAsync_WhenDataIsNil_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(data: nil)
        )
        await #expect(throws: NetworkingError.internalError(.unknown)) {
            try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        }
    }
    
    // MARK: Unit test for perform request with Async Await and Request Protocol and return Decodable

    @Test("test PerformAsync WithoutResponse Success")
    func test_PerformAsync_WithoutResponse_Success() async throws {
        let sut = createAsyncRequestPerformer()
        await #expect(throws: Never.self) { try await sut.perform(request: MockRequest()) }
    }
    
    @Test("test PerformAsync WithoutResponse WhenStatusCode300 Success")
    func test_PerformAsync_WithoutResponse_WhenStatusCode300_Success() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        await #expect(throws: NetworkingError.redirect(.multipleChoices, [:])) {
            try await sut.perform(request: MockRequest())
        }
    }
    
    @Test("test PerformAsync WithoutResponse WhenStatusCodeIsNot200 Fails")
    func test_PerformAsync_WithoutResponse_WhenStatusCodeIsNot200_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        await #expect(throws: NetworkingError.httpClientError(.badRequest, [:])) {
            try await sut.perform(request: MockRequest())
        }
    }
    
    @Test("test PerformAsync WithoutResponse WhenThereIsError Fails")
    func test_PerformAsync_WithoutResponse_WhenThereIsError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpClientError(.badRequest, [:]))
        )
        await #expect(throws: NetworkingError.httpClientError(.badRequest, [:])) {
            try await sut.perform(request: MockRequest())
        }
    }
    
    @Test("test PerformAsync WithoutResponse WhenThereIsHTTPError Fails")
    func test_PerformAsync_WithoutResponse_WhenThereIsHTTPError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpClientError(.forbidden, [:]))
        )
        await #expect(throws: NetworkingError.httpClientError(.forbidden, [:])) {
            try await sut.perform(request: MockRequest())
        }
    }
    
    @Test("test PerformAsync WithoutResponse WhenThereIsURLError Fails")
    func test_PerformAsync_WithoutResponse_WhenThereIsURLError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: URLError(.networkConnectionLost))
        )
        await #expect(throws: NetworkingError.urlError(URLError(.networkConnectionLost))) {
            try await sut.perform(request: MockRequest())
        }
    }
    
    @Test("test PerformAsync WithoutResponse WhenDataCannotBeDecodedToTypeEvenThoughDataWillNotBeDecoded Succeeds")
    func test_PerformAsync_WithoutResponse_WhenDataCannotBeDecodedToTypeEvenThoughDataWillNotBeDecoded_Succeeds() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(data: MockData.invalidMockPersonJsonData)
        )
        await #expect(throws: Never.self) { try await sut.perform(request: MockRequest()) }
    }
    
    @Test("test PerformAsync WithoutResponse WhenDataIsNil Fails")
    func test_PerformAsync_WithoutResponse_WhenDataIsNil_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(data: nil)
        )
        await #expect(throws: NetworkingError.internalError(.unknown)) {
            try await sut.perform(request: MockRequest())
        }
    }
}

private func createAsyncRequestPerformer(
    urlSession: URLSessionTaskProtocol = createMockURLSession(),
    validator: ResponseValidator = ResponseValidatorImpl(),
    requestDecoder: RequestDecodable = RequestDecoder()
) -> AsyncRequestPerformer {
    return AsyncRequestPerformer(urlSession: urlSession, validator: validator, requestDecoder: requestDecoder)
}

private func createMockURLSession(
    data: Data? = MockData.mockPersonJsonData,
    statusCode: Int = 200,
    error: Error? = nil
) -> MockURLSession {
    return MockURLSession(
        data: data,
        urlResponse: buildResponse(statusCode: statusCode),
        error: error
    )
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
