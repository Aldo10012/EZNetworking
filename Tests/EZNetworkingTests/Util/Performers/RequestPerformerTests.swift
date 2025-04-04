import XCTest
@testable import EZNetworking

final class RequestPerformerTests: XCTestCase {

    // MARK: Unit tests for perform using Completion Handler with Request Protocol

    func test_PerformTask_CanCancel() throws {
        let sut = createRequestPerformer()
        
        let task = sut.performTask(request: MockRequest(), decodeTo: Person.self) { _ in }
        task?.cancel()
        let dataTask = try XCTUnwrap(task as? MockURLSessionDataTask)
        XCTAssertTrue(dataTask.didCancel)
    }
    
    func test_PerformTask_DoesDecodePerson() {
        let sut = createRequestPerformer()
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success(let person):
                XCTAssertEqual(person.name, "John")
                XCTAssertEqual(person.age, 30)
            case .failure:
                XCTFail()
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformTask_WhenStatusCode300_Faile() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.redirect(.multipleChoices, [:]))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformTask_WhenStatusCodeIs400_Data() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpClientError(.badRequest, [:]))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformTask_WhenDataIsInvalid_Fails() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: MockData.invalidMockPersonJsonData)
        )
        
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.internalError(.couldNotParse))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformTask_WhenDataIsNil_Fails() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: nil)
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.internalError(.noData))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformTask_WhenURLSessionHasError_Data() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.internalError(.unknown))
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.internalError(.requestFailed(NetworkingError.internalError(.unknown))))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformTask_WhenURLSessionHasURLError_Data() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: URLError(.networkConnectionLost))
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.urlError(URLError(.networkConnectionLost)))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: Unit tests for perform using Completion Handler and Requesst Protocol without Decodable response
    
    func test_PerformTask_WithoutDecodable_CanCancel() throws {
        let sut = createRequestPerformer()
        let task = sut.performTask(request: MockRequest()) { _ in }
        task?.cancel()
        let dataTask = try XCTUnwrap(task as? MockURLSessionDataTask)
        XCTAssertTrue(dataTask.didCancel)
    }
    
    func test_PerformTask_WithoutDecodable_DoesPass() {
        let sut = createRequestPerformer()
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest()) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail()
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformTask_WithoutDecodable_WhenStatusCode300_Fails() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 300)
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest()) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.redirect(.multipleChoices, [:]))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformTask_WithoutDecodable_WhenStatusCodeIs400_Fails() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest()) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpClientError(.badRequest, [:]))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformTask_WithoutDecodable_WhenDataIsInvalid_Fails() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: MockData.invalidMockPersonJsonData)
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest()) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTAssert(true)
            case .failure(let error):
                XCTFail()
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformTask_WithoutDecodable_WhenDataIsNil_Fails() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: nil)
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest()) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.internalError(.noData))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformTask_WithoutDecodable_WhenURLSessionHasURLError_Data() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: URLError(.networkConnectionLost))
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest()) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.urlError(URLError(.networkConnectionLost)))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
}

private func createRequestPerformer(
    urlSession: URLSessionTaskProtocol = createMockURLSession(),
    validator: ResponseValidator = ResponseValidatorImpl(),
    requestDecoder: RequestDecodable = RequestDecoder()
) -> RequestPerformer {
    return RequestPerformer(urlSession: urlSession, validator: validator, requestDecoder: requestDecoder)
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
