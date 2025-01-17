import UIKit
import XCTest
@testable import EZNetworking

final class RequestPerformerTests: XCTestCase {

    // MARK: Unit tests for perform using Completion Handler

    func test_PerformWithCompletionHandler_DoesDecodePerson() throws {
        let sut = createRequestPerformer()
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let exp = XCTestExpectation()
        sut.performTask(request: request, decodeTo: Person.self) { result in
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
    
    func test_PerformWithCompletionHandler_CanCancel() throws {
        let sut = createRequestPerformer()
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        let task = sut.performTask(request: request, decodeTo: Person.self) { _ in }
        
        task.cancel()
        let dataTask = try XCTUnwrap(task as? MockURLSessionDataTask)
        XCTAssertTrue(dataTask.didCancel)
    }
    
    func test_PerformWithCompletionHandler_WhenDataIsInvalid_Fails() throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: invalidMockPersonJsonData)
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let exp = XCTestExpectation()
        sut.performTask(request: request, decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.couldNotParse)
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WhenDataIsNil_Fails() throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: nil)
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let exp = XCTestExpectation()
        sut.performTask(request: request, decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noData)
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WhenStatusCodeIsNot200_Fails() throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let exp = XCTestExpectation()
        sut.performTask(request: request, decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WhenURLSessionHasError_Fails() throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.unknown)
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let exp = XCTestExpectation()
        sut.performTask(request: request, decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.requestFailed(NetworkingError.unknown))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WhenResponseValidatorThrowsError_Fails() throws {
        let sut = createRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.unknown)
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let exp = XCTestExpectation()
        sut.performTask(request: request, decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.unknown)
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: Unit tests for perform using Completion Handler with Request Protocol

    func test_PerformWithCompletionHandler_WithRequestProtocol_DoesDecodePerson() {
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
    
    func test_PerformWithCompletionHandler_WithRequestProtocol_CanCancel() throws {
        let sut = createRequestPerformer()
        
        let task = sut.performTask(request: MockRequest(), decodeTo: Person.self) { _ in }
        task.cancel()
        let dataTask = try XCTUnwrap(task as? MockURLSessionDataTask)
        XCTAssertTrue(dataTask.didCancel)
    }
    
    func test_PerformWithCompletionHandler_WithRequestProtocol_WhenDataIsInvalid_Fails() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: invalidMockPersonJsonData)
        )
        
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.couldNotParse)
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WithRequestProtocol_WhenDataIsNil_Fails() {
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
                XCTAssertEqual(error, NetworkingError.noData)
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WithRequestProtocol_WhenStatusCodeIsNot200_Data() {
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
                XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WithRequestProtocol_WhenURLSessionHasError_Data() {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.unknown)
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.requestFailed(NetworkingError.unknown))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WithRequestProtocol_WhenResponseValidatorThrowsError_fails() {
        let sut = RequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.unknown)
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.unknown)
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: Unit tests for perform using Completion Handler without Decodable response
    
    func test_PerformWithCompletionHandler_WithoutDecodable_DoesPass() throws {
        let sut = createRequestPerformer()
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let exp = XCTestExpectation()
        sut.performTask(request: request) { result in
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
    
    func test_PerformWithCompletionHandler_WithoutDecodable_CanCancel() throws {
        let sut = createRequestPerformer()
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let task = sut.performTask(request: request) { _ in }
        task.cancel()
        let dataTask = try XCTUnwrap(task as? MockURLSessionDataTask)
        XCTAssertTrue(dataTask.didCancel)
    }
    
    func test_PerformWithCompletionHandler_WithoutDecodable_WhenDataIsNil_Fails() throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(data: nil)
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let exp = XCTestExpectation()
        sut.performTask(request: request) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noData)
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WithoutDecodable_WhenStatusCodeIsNot200_Fails() throws {
        let sut = createRequestPerformer(
            urlSession: createMockURLSession(statusCode: 400)
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let exp = XCTestExpectation()
        sut.performTask(request: request) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WithoutDecodable_WhenResponseValidatorThrowsError_Fails() throws {
        let sut = createRequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.unknown)
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let exp = XCTestExpectation()
        sut.performTask(request: request) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.unknown)
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: Unit tests for perform using Completion Handler and Requesst Protocol without Decodable response
    
    func test_PerformWithCompletionHandler_WithoutDecodable_WithRequestProtocol_DoesPass() {
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
    
    func test_PerformWithCompletionHandler_WithoutDecodable_WithRequestProtocol_CanCancel() throws {
        let sut = createRequestPerformer()
        let task = sut.performTask(request: MockRequest()) { _ in }
        task.cancel()
        let dataTask = try XCTUnwrap(task as? MockURLSessionDataTask)
        XCTAssertTrue(dataTask.didCancel)
    }
    
    func test_PerformWithCompletionHandler_WithoutDecodable_WithRequestProtocol_WhenDataIsNil_Fails() {
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
                XCTAssertEqual(error, NetworkingError.noData)
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WithoutDecodable_WithRequestProtocol_WhenStatusCodeIsNot200_Fails() {
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
                XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WithoutDecodable_WithRequestProtocol_WhenResponseValidatorThrowsError_Fails() {
        let sut = RequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.unknown)
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest()) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.unknown)
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
}

private func createRequestPerformer(
    urlSession: URLSessionTaskProtocol = createMockURLSession(),
    urlResponseValidator: URLResponseValidator = URLResponseValidatorImpl(),
    requestDecoder: RequestDecodable = RequestDecoder()
) -> RequestPerformer {
    return RequestPerformer(urlSession: urlSession, urlResponseValidator: urlResponseValidator, requestDecoder: requestDecoder)
}

private func createMockURLSession(
    data: Data? = mockPersonJsonData,
    statusCode: Int = 200,
    error: Error? = nil
) -> MockURLSession {
    return MockURLSession(
        data: data,
        urlResponse: buildResponse(statusCode: statusCode),
        error: error
    )
}

private var sampleUrlRequest = RequestFactoryImpl().build(httpMethod: .GET, baseUrlString: "https://www.example.com", parameters: nil)

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
