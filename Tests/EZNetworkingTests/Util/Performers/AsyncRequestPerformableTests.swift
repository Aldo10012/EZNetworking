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
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
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
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
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
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
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
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
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
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
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
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
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
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
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
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
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
    
    
    // MARK: Unit tests for downloadImage
    
    func testDownloadImageSuccess() async throws { // note: this is an async test as it actually decodes url to generate the image
        let testURL = URL(string: "https://i.natgeofe.com/n/4f5aaece-3300-41a4-b2a8-ed2708a0a27c/domestic-dog_thumb_square.jpg")!
        let sut = AsyncRequestPerformer()
        do {
            _ = try await sut.downloadImage(from: testURL)
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
    
    func testDownloadImageFails() async throws {
        let testURL = URL(string: "https://i.natgeofe.com/n/4f5aaece-3300-41a4-b2a8-ed2708a0a27c/domestic-dog_thumb_square.jpg")!
        let urlSession = MockURLSession(data: mockPersonJsonData,
                                        url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpError(.badRequest))
        let sut = AsyncRequestPerformer(urlSession: urlSession,
                                   urlResponseValidator: validator,
                                   requestDecoder: RequestDecoder())
        do {
            _ = try await sut.downloadImage(from: testURL)
            XCTFail()
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
        }
    }

    
    private func buildResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }
}
