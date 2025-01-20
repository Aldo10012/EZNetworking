import UIKit
import XCTest
@testable import EZNetworking

final class RequestPerformerTests: XCTestCase {

    // MARK: Unit tests for perform using Completion Handler

    func testPerformWithCompletionHandlerDoesDecodePerson() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
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
    
    func testPerformWithCompletionHandlerCanCancel() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        let task = sut.performTask(request: request, decodeTo: Person.self) { _ in }
        
        task.cancel()
        let dataTask = try XCTUnwrap(task as? MockURLSessionDataTask)
        XCTAssertTrue(dataTask.didCancel)
    }
    
    func testPerformWithCompletionHandlerWithErrorFails() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(error: HTTPNetworkingError.forbidden),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden)),
            requestDecoder: RequestDecoder()
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let exp = XCTestExpectation()
        sut.performTask(request: request, decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func testPerformWithCompletionHandlerWithBadStatusCodeFails() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(statusCode: 400),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.badRequest)),
            requestDecoder: RequestDecoder()
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
    
    func testPerformWithCompletionHandlerWithInvalidData() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(data: invalidMockPersonJsonData),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
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
    
    func testPerformWithCompletionHandlerWithNilData() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(data: nil),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
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
    
    func testPerformWithCompletionHandlerWithNilResponse() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(data: invalidMockPersonJsonData),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
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
    
    // MARK: Unit tests for perform using Completion Handler with Request Protocol

    func testPerformWithCompletionHandlerWithRequestProtocolDoesDecodePerson() {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
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
    
    func testPerformWithCompletionHandlerWithRequestProtocolCanCancel() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
        
        let task = sut.performTask(request: MockRequest(), decodeTo: Person.self) { _ in }
        task.cancel()
        let dataTask = try XCTUnwrap(task as? MockURLSessionDataTask)
        XCTAssertTrue(dataTask.didCancel)
    }
    
    func testPerformWithCompletionHandlerWithRequestProtocolWithErrorFails() {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(error: HTTPNetworkingError.forbidden),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden)),
            requestDecoder: RequestDecoder()
        )
        
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func testPerformWithCompletionHandlerWithRequestProtocolWithBadStatusCodeFails() {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(statusCode: 400),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.badRequest)),
            requestDecoder: RequestDecoder()
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
    
    func testPerformWithCompletionHandlerWithRequestProtocolWithInvalidData() {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(data: invalidMockPersonJsonData),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
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
    
    func testPerformWithCompletionHandlerWithRequestProtocolWithNilData() {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(data: nil),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
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
    
    func testPerformWithCompletionHandlerWithRequestProtocolWithNilResponse() {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(data: invalidMockPersonJsonData),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
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
    
    // MARK: Unit tests for perform using Completion Handler without Decodable response
    
    func testPerformWithCompletionHandlerWithoutDecodableDoesDecodePerson() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
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
    
    func testPerformWithCompletionHandlerWithoutDecodableCanCancel() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let task = sut.performTask(request: request) { _ in }
        task.cancel()
        let dataTask = try XCTUnwrap(task as? MockURLSessionDataTask)
        XCTAssertTrue(dataTask.didCancel)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithErrorFails() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpError(.forbidden)),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden)),
            requestDecoder: RequestDecoder()
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let exp = XCTestExpectation()
        sut.performTask(request: request) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithBadStatusCodeFails() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(statusCode: 400),
            urlResponseValidator: URLResponseValidatorImpl(),
            requestDecoder: RequestDecoder()
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
    
    func testPerformWithCompletionHandlerWithoutDecodableWithNilData() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(data: nil),
            urlResponseValidator: URLResponseValidatorImpl(),
            requestDecoder: RequestDecoder()
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
    
    func testPerformWithCompletionHandlerWithoutDecodableWithNilResponse() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(statusCode: nil),
            urlResponseValidator: URLResponseValidatorImpl(),
            requestDecoder: RequestDecoder()
        )
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        let exp = XCTestExpectation()
        sut.performTask(request: request) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noResponse)
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: Unit tests for perform using Completion Handler and Requesst Protocol without Decodable response
    
    func testPerformWithCompletionHandlerWithoutDecodableWithRequestProtocolDoesDecodePerson() {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
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
    
    func testPerformWithCompletionHandlerWithoutDecodableWithRequestProtocolCanCancel() throws {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(),
            urlResponseValidator: MockURLResponseValidator(),
            requestDecoder: RequestDecoder()
        )
        let task = sut.performTask(request: MockRequest()) { _ in }
        task.cancel()
        let dataTask = try XCTUnwrap(task as? MockURLSessionDataTask)
        XCTAssertTrue(dataTask.didCancel)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithRequestProtocolWithErrorFails() {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(error: NetworkingError.httpError(.forbidden)),
            urlResponseValidator: MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden)),
            requestDecoder: RequestDecoder()
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest()) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithRequestProtocolWithBadStatusCodeFails() {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(statusCode: 400),
            urlResponseValidator: URLResponseValidatorImpl(),
            requestDecoder: RequestDecoder()
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
    
    func testPerformWithCompletionHandlerWithoutDecodableWithRequestProtocolWithNilData() {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(data: nil),
            urlResponseValidator: URLResponseValidatorImpl(),
            requestDecoder: RequestDecoder()
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
    
    func testPerformWithCompletionHandlerWithoutDecodableWithRequestProtocolWithNilResponse() {
        let sut = RequestPerformer(
            urlSession: createMockURLSession(statusCode: nil),
            urlResponseValidator: URLResponseValidatorImpl(),
            requestDecoder: RequestDecoder()
        )
        let exp = XCTestExpectation()
        sut.performTask(request: MockRequest()) { result in
            defer { exp.fulfill() }
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noResponse)
            }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    private func createMockURLSession(data: Data? = mockPersonJsonData,
                                      statusCode: Int? = 200,
                                      error: Error? = nil) -> MockURLSession {
        let urlResponse: HTTPURLResponse? = (statusCode != nil) ? buildResponse(statusCode: statusCode!) : nil
        return MockURLSession(
            data: data,
            urlResponse: urlResponse,
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
