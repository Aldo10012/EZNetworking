import XCTest
@testable import EZNetworking

final class AsyncRequestPerformableTests: XCTestCase {
    
    // MARK: Unit test for perform request with Async Await and return Decodable

    func testPerformAsyncSuccess() async throws {
        let sut = createAsyncRequestPerformer()
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        let person = try await sut.perform(request: request, decodeTo: Person.self)
        XCTAssertEqual(person.name, "John")
        XCTAssertEqual(person.age, 30)
    }
    
    func testPerformAsyncFailsWhenStatusCodeIsNot200() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: request, decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncFailsWhenThereIsError() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpError(.badRequest))
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: request, decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncFailsWhenThereIsValidatorThrowsHttpError() async throws {
        let sut = createAsyncRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden))
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: request, decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpError(.forbidden))
        }
    }
    
    func testPerformAsyncFailsWhenThereIsValidatorThrowsURLError() async throws {
        let sut = createAsyncRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.networkConnectionLost)))
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: request, decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.urlError(URLError(.networkConnectionLost)))
        }
    }
    
    // MARK: Unit test for perform request with Async Await and Request protocol and return Decodable

    func testPerformAsyncWithRequestProtocolSuccess() async throws {
        let sut = createAsyncRequestPerformer()
        let person = try await sut.perform(request: MockRequest(), decodeTo: Person.self)
        XCTAssertEqual(person.name, "John")
        XCTAssertEqual(person.age, 30)
    }
    
    func testPerformAsyncWithRequestProtocolFailsWhenStatusCodeIsNot200() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncWithRequestProtocolFailsWhenThereIsError() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpError(.badRequest))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncWithRequestProtocolFailsWhenThereIsValidatorThrowsHttpError() async throws {
        let sut = createAsyncRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpError(.forbidden))
        }
    }
    
    func testPerformAsyncWithRequestProtocolFailsWhenThereIsValidatorThrowsURLError() async throws {
        let sut = createAsyncRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.networkConnectionLost)))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest(), decodeTo: Person.self)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.urlError(URLError(.networkConnectionLost)))
        }
    }
    
    // MARK: Unit test for perform request with Async Await and return Decodable

    func testPerformAsyncWithoutResponseSuccess() async throws {
        let sut = createAsyncRequestPerformer()
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        await XCTAssertNoThrowAsync(try await sut.perform(request: request))
    }
    
    func testPerformAsyncWithoutResponseFailsWhenStatusCodeIsNot200() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: request)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncWIthoutResponseFailsWhenThereIsError() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpError(.badRequest))
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: request)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncWithoutResponseFailsWhenThereIsValidatorThrowsHTTPError() async throws {
        let sut = createAsyncRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden))
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: request)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpError(.forbidden))
        }
    }
    
    func testPerformAsyncWithoutResponseFailsWhenThereIsValidatorThrowsURLError() async throws {
        let sut = createAsyncRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.cannotConnectToHost)))
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: request)) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.urlError(URLError(.cannotConnectToHost)))
        }
    }
    
    // MARK: Unit test for perform request with Async Await and Request Protocol and return Decodable

    func testPerformAsyncWithRequestProtocolWithoutResponseSuccess() async throws {
        let sut = createAsyncRequestPerformer()
        await XCTAssertNoThrowAsync(try await sut.perform(request: MockRequest()))
    }
    
    func testPerformAsyncWithRequestProtocolWithoutResponseFailsWhenStatusCodeIsNot200() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncWithRequestProtocolWIthoutResponseFailsWhenThereIsError() async throws {
        let sut = createAsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpError(.badRequest))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncWithRequestProtocolWithoutResponseFailsWhenThereIsValidatorThrowsHTTPError() async throws {
        let sut = createAsyncRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.httpError(.forbidden))
        }
    }
    
    func testPerformAsyncWithRequestProtocolWithoutResponseFailsWhenThereIsValidatorThrowsURLError() async throws {
        let sut = createAsyncRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.cannotConnectToHost)))
        )
        await XCTAssertThrowsErrorAsync(try await sut.perform(request: MockRequest())) { error in
            XCTAssertEqual(error as! NetworkingError, NetworkingError.urlError(URLError(.cannotConnectToHost)))
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

private var sampleUrlRequest = RequestBuilder().build(httpMethod: .GET, baseUrlString: "https://www.example.com", parameters: nil)

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
    var header: [HTTPHeader]? { nil }
    var body: Data? { nil }
}
