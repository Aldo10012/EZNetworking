import UIKit
import XCTest
@testable import EZNetworking

final class RequestPerformerTests: XCTestCase {

    // MARK: Unit tests for perform using Completion Handler

    func testPerformWithCompletionHandlerDoesDecodePerson() throws {
        let urlSession = createMockURLSession(
            data: mockPersonJsonData,
            statusCode: 200,
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        var didExecute = false
        sut.performTask(request: request, decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success(let person):
                XCTAssertEqual(person.name, "John")
                XCTAssertEqual(person.age, 30)
            case .failure:
                XCTFail()
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithErrorFails() throws {
        let urlSession = createMockURLSession(
            data: mockPersonJsonData,
            statusCode: 200,
            error: HTTPNetworkingError.forbidden
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden))
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        var didExecute = false
        sut.performTask(request: request, decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithBadStatusCodeFails() throws {
        let urlSession = createMockURLSession(
            data: mockPersonJsonData,
            statusCode: 400,
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpError(.badRequest))
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        var didExecute = false
        sut.performTask(request: request, decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithInvalidData() throws {
        let urlSession = createMockURLSession(
            data: invalidMockPersonJsonData,
            statusCode: 200,
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        var didExecute = false
        sut.performTask(request: request, decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.couldNotParse)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithNilData() throws {
        let urlSession = createMockURLSession(
            data: nil,
            statusCode: 200,
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        var didExecute = false
        sut.performTask(request: request, decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noData)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithNilResponse() throws {
        let urlSession = createMockURLSession(
            data: invalidMockPersonJsonData,
            statusCode: nil,
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        var didExecute = false
        sut.performTask(request: request, decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.couldNotParse)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    // MARK: Unit tests for perform using Completion Handler with Request Protocol

    func testPerformWithCompletionHandlerWithRequestProtocolDoesDecodePerson() {
        let urlSession = createMockURLSession(
            data: mockPersonJsonData,
            statusCode: 200,
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success(let person):
                XCTAssertEqual(person.name, "John")
                XCTAssertEqual(person.age, 30)
            case .failure:
                XCTFail()
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithRequestProtocolWithErrorFails() {
        let urlSession = createMockURLSession(
            data: mockPersonJsonData,
            statusCode: 200,
            error: HTTPNetworkingError.forbidden
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden))
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithRequestProtocolWithBadStatusCodeFails() {
        let urlSession = createMockURLSession(
            data: mockPersonJsonData,
            statusCode: 400,
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpError(.badRequest))
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithRequestProtocolWithInvalidData() {
        let urlSession = createMockURLSession(
            data: invalidMockPersonJsonData,
            statusCode: 200,
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.couldNotParse)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithRequestProtocolWithNilData() {
        let urlSession = createMockURLSession(
            data: nil,
            statusCode: 200,
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noData)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithRequestProtocolWithNilResponse() {
        let urlSession = createMockURLSession(
            data: invalidMockPersonJsonData,
            statusCode: nil,
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        var didExecute = false
        sut.performTask(request: MockRequest(), decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.couldNotParse)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    // MARK: Unit tests for perform using Completion Handler without Decodable response
    
    func testPerformWithCompletionHandlerWithoutDecodableDoesDecodePerson() throws {
        let urlSession = createMockURLSession(
            data: mockPersonJsonData,
            statusCode: 200,
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        var didExecute = false
        sut.performTask(request: request) { result in
            didExecute = true
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail()
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithErrorFails() throws {
        let urlSession = createMockURLSession(
            data: mockPersonJsonData,
            statusCode: 200,
            error: NetworkingError.httpError(.forbidden)
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden))
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        var didExecute = false
        sut.performTask(request: request) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithBadStatusCodeFails() throws {
        let urlSession = createMockURLSession(
            data: mockPersonJsonData,
            statusCode: 400,
            error: nil
        )
        let validator = URLResponseValidatorImpl()
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        var didExecute = false
        sut.performTask(request: request) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithNilData() throws {
        let urlSession = createMockURLSession(
            data: nil,
            statusCode: 200,
            error: nil
        )
        let validator = URLResponseValidatorImpl()
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        var didExecute = false
        sut.performTask(request: request) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noData)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithNilResponse() throws {
        let urlSession = createMockURLSession(
            data: invalidMockPersonJsonData,
            statusCode: nil,
            error: nil
        )
        let validator = URLResponseValidatorImpl()
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        let request = try XCTUnwrap(sampleUrlRequest, "Failed to create URLRequest")
        
        var didExecute = false
        sut.performTask(request: request) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noResponse)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    // MARK: Unit tests for perform using Completion Handler and Requesst Protocol without Decodable response
    
    func testPerformWithCompletionHandlerWithoutDecodableWithRequestProtocolDoesDecodePerson() {
        let urlSession = createMockURLSession(
            data: mockPersonJsonData,
            statusCode: 200,
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        var didExecute = false
        sut.performTask(request: MockRequest()) { result in
            didExecute = true
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail()
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithRequestProtocolWithErrorFails() {
        let urlSession = createMockURLSession(
            data: mockPersonJsonData,
            statusCode: 200,
            error: NetworkingError.httpError(.forbidden)
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.httpError(.forbidden))
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        var didExecute = false
        sut.performTask(request: MockRequest()) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.forbidden))
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithRequestProtocolWithBadStatusCodeFails() {
        let urlSession = createMockURLSession(
            data: mockPersonJsonData,
            statusCode: 400,
            error: nil
        )
        let validator = URLResponseValidatorImpl()
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        var didExecute = false
        sut.performTask(request: MockRequest()) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.httpError(.badRequest))
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithRequestProtocolWithNilData() {
        let urlSession = createMockURLSession(
            data: nil,
            statusCode: 200,
            error: nil
        )
        let validator = URLResponseValidatorImpl()
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        var didExecute = false
        sut.performTask(request: MockRequest()) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noData)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithRequestProtocolWithNilResponse() {
        let urlSession = createMockURLSession(
            data: invalidMockPersonJsonData,
            statusCode: nil,
            error: nil
        )
        let validator = URLResponseValidatorImpl()
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        var didExecute = false
        sut.performTask(request: MockRequest()) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noResponse)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    private func createMockURLSession(data: Data?,
                                      statusCode: Int?,
                                      error: Error?) -> MockURLSession {
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
