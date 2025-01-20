import XCTest
@testable import EZNetworking

final class AsyncRequestPerformableTests: XCTestCase {
    
    // MARK: Unit test for perform request with Async Await and return Decodable

    func testPerformAsyncSuccess() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        do {
            let person: Person = try await sut.perform(request: request, decodeTo: Person.self)
            XCTAssertEqual(person.name, "John")
            XCTAssertEqual(person.age, 30)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testPerformAsyncFailsWhenThereIsError() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpError(.badRequest)),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        do {
            _ = try await sut.perform(request: request, decodeTo: Person.self)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncFailsWhenThereIsValidatorThrowsHttpError() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden)),
            requestDecoder: RequestDecoder()
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        do {
            _ = try await sut.perform(request: request, decodeTo: Person.self)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
        }
    }
    
    func testPerformAsyncFailsWhenThereIsValidatorThrowsURLError() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.networkConnectionLost))),
            requestDecoder: RequestDecoder()
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        do {
            _ = try await sut.perform(request: request, decodeTo: Person.self)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.urlError(URLError(.networkConnectionLost)))
        }
    }
    
    // MARK: Unit test for perform request with Async Await and Request protocol and return Decodable

    func testPerformAsyncWithRequestProtocolSuccess() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
        do {
            let person: Person = try await sut.perform(request: MockRequest(), decodeTo: Person.self)
            XCTAssertEqual(person.name, "John")
            XCTAssertEqual(person.age, 30)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testPerformAsyncWithRequestProtocolFailsWhenThereIsError() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpError(.badRequest)),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
        do {
            _ = try await sut.perform(request: MockRequest(), decodeTo: Person.self)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncWithRequestProtocolFailsWhenThereIsValidatorThrowsHttpError() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden)),
            requestDecoder: RequestDecoder()
        )
        do {
            _ = try await sut.perform(request: MockRequest(), decodeTo: Person.self)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
        }
    }
    
    func testPerformAsyncWithRequestProtocolFailsWhenThereIsValidatorThrowsURLError() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.networkConnectionLost))),
            requestDecoder: RequestDecoder()
        )
        do {
            _ = try await sut.perform(request: MockRequest(), decodeTo: Person.self)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.urlError(URLError(.networkConnectionLost)))
        }
    }
    
    // MARK: Unit test for perform request with Async Await and return Decodable

    func testPerformAsyncWithoutResponseSuccess() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        do {
            try await sut.perform(request: request)
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testPerformAsyncWIthoutResponseFailsWhenThereIsError() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpError(.badRequest)),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        do {
            try await sut.perform(request: request)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncWithoutResponseFailsWhenThereIsValidatorThrowsHTTPError() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden)),
            requestDecoder: RequestDecoder()
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        do {
            try await sut.perform(request: request)
            XCTFail()
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
        }
    }
    
    func testPerformAsyncWithoutResponseFailsWhenThereIsValidatorThrowsURLError() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.cannotConnectToHost))),
            requestDecoder: RequestDecoder()
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        do {
            try await sut.perform(request: request)
            XCTFail()
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.urlError(URLError(.cannotConnectToHost)))
        }
    }
    
    // MARK: Unit test for perform request with Async Await and Request Protocol and return Decodable

    func testPerformAsyncWithRequestProtocolWithoutResponseSuccess() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
        do {
            try await sut.perform(request: MockRequest())
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testPerformAsyncWithRequestProtocolWIthoutResponseFailsWhenThereIsError() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpError(.badRequest)),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
        do {
            try await sut.perform(request: MockRequest())
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncWithRequestProtocolWithoutResponseFailsWhenThereIsValidatorThrowsHTTPError() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden)),
            requestDecoder: RequestDecoder()
        )
        do {
            try await sut.perform(request: MockRequest())
            XCTFail()
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
        }
    }
    
    func testPerformAsyncWithRequestProtocolWithoutResponseFailsWhenThereIsValidatorThrowsURLError() async throws {
        let sut = AsyncRequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.cannotConnectToHost))),
            requestDecoder: RequestDecoder()
        )
        do {
            try await sut.perform(request: MockRequest())
            XCTFail()
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.urlError(URLError(.cannotConnectToHost)))
        }
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
}

private struct MockRequest: Request {
    var httpMethod: HTTPMethod { .GET }
    var baseUrlString: String { "https://www.example.com" }
    var parameters: [HTTPParameter]? { nil }
    var header: [HTTPHeader]? { nil }
    var body: Data? { nil }
}
