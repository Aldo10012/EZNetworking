import XCTest
@testable import EZNetworking

final class AsyncRequestPerformableTests: XCTestCase {
    
    // MARK: Unit test for perform request with Async Await and Request protocol and return Decodable

    func test_PerformAsync_Success() async throws {
        let sut = createAsyncRequestPerformer()
        let person = try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        XCTAssertEqual(person.name, "John")
        XCTAssertEqual(person.age, 30)
    }
    
    func test_PerformAsync_StatusCode300_Success() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.redirect(.multipleChoices))
        }
    }
    
    func test_PerformAsync_WhenStatusCodeIsNot200_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpClientError(.badRequest))
        }
    }
    
    func test_PerformAsync_WhenThereIsError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpClientError(.badRequest))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpClientError(.badRequest))
        }
    }
    
    func test_PerformAsync_WhenThereIsValidatorThrowsHttpError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpClientError(.forbidden))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpClientError(.forbidden))
        }
    }
    
    func test_PerformAsync_WhenThereIsValidatorThrowsURLError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.networkConnectionLost)))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.urlError(URLError(.networkConnectionLost)))
        }
    }
    
    func test_PerformAsync_WhenRequestCannotBuildURLRequest_Fails() async throws {
        let sut = createAsyncRequestPerformer()
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequestWithNilBuild(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.internalError(.noRequest))
        }
    }
    
    // MARK: Unit test for perform request with Async Await and Request Protocol and return Decodable

    func test_PerformAsync_WithoutResponse_Success() async throws {
        let sut = createAsyncRequestPerformer()
        await XCTAssertNoThrowAsync(try await sut.perform(request: MockRequest()))
    }
    
    func test_PerformAsync_WithoutResponse_WhenStatusCode300_Success() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.redirect(.multipleChoices))
        }    }
    
    func test_PerformAsync_WithoutResponse_WhenStatusCodeIsNot200_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpClientError(.badRequest))
        }
    }
    
    func test_PerformAsync_WithoutResponse_WhenThereIsError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpClientError(.badRequest))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpClientError(.badRequest))
        }
    }
    
    func test_PerformAsync_WithoutResponse_WhenThereIsValidatorThrowsHTTPError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpClientError(.forbidden))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpClientError(.forbidden))
        }
    }
    
    func test_PerformAsync_WithoutResponse_WhenThereIsValidatorThrowsURLError_Fails() async throws {
        let sut = createAsyncRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.cannotConnectToHost)))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.urlError(URLError(.cannotConnectToHost)))
        }
    }
    
    func test_PerformAsync_WithoutResponse_WhenRequestCannotBuildURLRequest_Fails() async throws {
        let sut = createAsyncRequestPerformer()
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequestWithNilBuild())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.internalError(.noRequest))
        }
    }
}

private func createAsyncRequestPerformer(
    urlSession: URLSessionTaskProtocol = createMockURLSession(),
    urlResponseValidator: URLResponseValidator = URLResponseValidatorImpl(),
    requestDecoder: RequestDecodable = RequestDecoder()
) -> AsyncRequestPerformer {
    return AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: urlResponseValidator, requestDecoder: requestDecoder)
}

private func createMockURLSession(
    statusCode: Int = 200,
    error: Error? = nil
) -> MockURLSession {
    return MockURLSession(
        data: mockPersonJsonData,
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
    var body: Data? { nil }
}

private struct MockRequestWithNilBuild: Request {
    var httpMethod: HTTPMethod { .GET }
    var baseUrlString: String { "https://www.example.com" }
    var parameters: [HTTPParameter]? { nil }
    var headers: [HTTPHeader]? { nil }
    var body: Data? { nil }
    var urlRequest: URLRequest? { nil }
}
