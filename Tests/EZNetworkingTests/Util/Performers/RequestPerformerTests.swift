import UIKit
import XCTest
@testable import EZNetworking

final class RequestPerformerTests: XCTestCase {

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
        task?.cancel()
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
                XCTAssertEqual(error, NetworkingError.internalError(.couldNotParse))
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
                XCTAssertEqual(error, NetworkingError.internalError(.noData))
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
                XCTAssertEqual(error, NetworkingError.httpClientError(.badRequest))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WithRequestProtocol_WhenURLSessionHasError_Data() {
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
    
    func test_PerformWithCompletionHandler_WithRequestProtocol_WhenResponseValidatorThrowsError_fails() {
        let sut = RequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.internalError(.unknown))
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.internalError(.unknown))
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
        task?.cancel()
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
                XCTAssertEqual(error, NetworkingError.internalError(.noData))
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
                XCTAssertEqual(error, NetworkingError.httpClientError(.badRequest))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_PerformWithCompletionHandler_WithoutDecodable_WithRequestProtocol_WhenResponseValidatorThrowsError_Fails() {
        let sut = RequestPerformer(
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.internalError(.unknown))
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest()) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.internalError(.unknown))
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
    var headers: [HTTPHeader]? { nil }
    var body: Data? { nil }
}
