import XCTest
@testable import EZNetworking

final class AsyncRequestPerformableTests: XCTestCase {
    
    // MARK: Unit test for perform request with Async Await and return Decodable

    func testPerformAsyncSuccess() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, baseUrlString: "https://www.example.com", parameters: nil) else {
            XCTFail("Failed to create URLRequest")
            return
        }
        
        do {
            let person: Person = try await sut.perform(request: request, decodeTo: Person.self)
            XCTAssertEqual(person.name, "John")
            XCTAssertEqual(person.age, 30)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testPerformAsyncFailsWhenThereIsError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: NetworkingError.httpError(.badRequest)
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, baseUrlString: "https://www.example.com", parameters: nil) else {
            XCTFail("Failed to create URLRequest")
            return
        }
        
        do {
            _ = try await sut.perform(request: request, decodeTo: Person.self)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncFailsWhenThereIsValidatorThrowsHttpError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden))
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, baseUrlString: "https://www.example.com", parameters: nil) else {
            XCTFail("Failed to create URLRequest")
            return
        }
        
        do {
            _ = try await sut.perform(request: request, decodeTo: Person.self)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
        }
    }
    
    func testPerformAsyncFailsWhenThereIsValidatorThrowsURLError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.networkConnectionLost)))
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, baseUrlString: "https://www.example.com", parameters: nil) else {
            XCTFail("Failed to create URLRequest")
            return
        }
        
        do {
            _ = try await sut.perform(request: request, decodeTo: Person.self)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.urlError(URLError(.networkConnectionLost)))
        }
    }
    
    // MARK: Unit test for perform request with Async Await and Request protocol and return Decodable

    func testPerformAsyncWithRequestProtocolSuccess() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)

        do {
            let person: Person = try await sut.perform(request: MockRequest(), decodeTo: Person.self)
            XCTAssertEqual(person.name, "John")
            XCTAssertEqual(person.age, 30)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testPerformAsyncWithRequestProtocolFailsWhenThereIsError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: NetworkingError.httpError(.badRequest)
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        do {
            _ = try await sut.perform(request: MockRequest(), decodeTo: Person.self)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncWithRequestProtocolFailsWhenThereIsValidatorThrowsHttpError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden))
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        do {
            _ = try await sut.perform(request: MockRequest(), decodeTo: Person.self)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
        }
    }
    
    func testPerformAsyncWithRequestProtocolFailsWhenThereIsValidatorThrowsURLError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.networkConnectionLost)))
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        do {
            _ = try await sut.perform(request: MockRequest(), decodeTo: Person.self)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.urlError(URLError(.networkConnectionLost)))
        }
    }
    
    // MARK: Unit test for perform request with Async Await and return Decodable

    func testPerformAsyncWithoutResponseSuccess() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, baseUrlString: "https://www.example.com", parameters: nil) else {
            XCTFail("Failed to create URLRequest")
            return
        }
        
        do {
            try await sut.perform(request: request)
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testPerformAsyncWIthoutResponseFailsWhenThereIsError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: NetworkingError.httpError(.badRequest)
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, baseUrlString: "https://www.example.com", parameters: nil) else {
            XCTFail("Failed to create URLRequest")
            return
        }
        
        do {
            try await sut.perform(request: request)
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncWithoutResponseFailsWhenThereIsValidatorThrowsHTTPError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden))
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, baseUrlString: "https://www.example.com", parameters: nil) else {
            XCTFail("Failed to create URLRequest")
            return
        }
        
        do {
            try await sut.perform(request: request)
            XCTFail()
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
        }
    }
    
    func testPerformAsyncWithoutResponseFailsWhenThereIsValidatorThrowsURLError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.cannotConnectToHost)))
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, baseUrlString: "https://www.example.com", parameters: nil) else {
            XCTFail("Failed to create URLRequest")
            return
        }
        
        do {
            try await sut.perform(request: request)
            XCTFail()
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.urlError(URLError(.cannotConnectToHost)))
        }
    }
    
    // MARK: Unit test for perform request with Async Await and Request Protocol and return Decodable

    func testPerformAsyncWithRequestProtocolWithoutResponseSuccess() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        do {
            try await sut.perform(request: MockRequest())
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testPerformAsyncWithRequestProtocolWIthoutResponseFailsWhenThereIsError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: NetworkingError.httpError(.badRequest)
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        do {
            try await sut.perform(request: MockRequest())
            XCTFail()
        } catch let error as NetworkingError{
            XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
        }
    }
    
    func testPerformAsyncWithRequestProtocolWithoutResponseFailsWhenThereIsValidatorThrowsHTTPError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden))
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        do {
            try await sut.perform(request: MockRequest())
            XCTFail()
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
        }
    }
    
    func testPerformAsyncWithRequestProtocolWithoutResponseFailsWhenThereIsValidatorThrowsURLError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.urlError(URLError(.cannotConnectToHost)))
        let decoder = RequestDecoder()
        let sut = AsyncRequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        do {
            try await sut.perform(request: MockRequest())
            XCTFail()
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.urlError(URLError(.cannotConnectToHost)))
        }
    }

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
