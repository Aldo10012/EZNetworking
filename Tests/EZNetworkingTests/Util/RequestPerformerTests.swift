//
//  RequestPerformerTests.swift
//  
//
//  Created by Alberto Dominguez on 7/14/24.
//

import XCTest
@testable import EZNetworking

final class RequestPerformerTests: XCTestCase {
    
    // MARK: Unit test for perform request with Async Await and return Decodable

    func testPerformAsyncSuccess() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(error: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
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
            error: NetworkingError.badRequest
        )
        let validator = MockURLResponseValidator(error: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail("Failed to create URLRequest")
            return
        }
        
        do {
            let person: Person = try await sut.perform(request: request, decodeTo: Person.self)
            XCTFail()
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    func testPerformAsyncFailsWhenThereIsValidatorThrowsError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(error: .forbidden)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail("Failed to create URLRequest")
            return
        }
        
        do {
            let person: Person = try await sut.perform(request: request, decodeTo: Person.self)
            XCTFail()
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    // MARK: Unit test for perform request with Async Await and return Decodable

    func testPerformAsyncWithoutResponseSuccess() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(error: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
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
            error: NetworkingError.badRequest
        )
        let validator = MockURLResponseValidator(error: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail("Failed to create URLRequest")
            return
        }
        
        do {
            try await sut.perform(request: request)
            XCTFail()
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    func testPerformAsyncWithoutResponseFailsWhenThereIsValidatorThrowsError() async throws {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(error: .forbidden)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail("Failed to create URLRequest")
            return
        }
        
        do {
            try await sut.perform(request: request)
            XCTFail()
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    // MARK: Unit tests for perform using Completion Handler
    
    func testPerformWithCompletionHandlerDoesDecodePerson() {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(error: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        sut.perform(request: request, decodeTo: Person.self) { result in
            switch result {
            case .success(let person):
                XCTAssertEqual(person.name, "John")
                XCTAssertEqual(person.age, 30)
            case .failure(let failure):
                XCTFail()
            }
        }
    }
    
    func testPerformWithCompletionHandlerWithErrorFails() {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: NetworkingError.forbidden
        )
        let validator = MockURLResponseValidator(error: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        sut.perform(request: request, decodeTo: Person.self) { result in
            switch result {
            case .success(let person):
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(true)
            }
        }
    }
    
    func testPerformWithCompletionHandlerWithBadStatusCodeFails() {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 400),
            error: nil
        )
        let validator = MockURLResponseValidator(error: NetworkingError.badRequest)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        sut.perform(request: request, decodeTo: Person.self) { result in
            switch result {
            case .success(let person):
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(true)
            }
        }
    }
    
    func testPerformWithCompletionHandlerWithInvalidData() {
        let urlSession = MockURLSession(
            data: invalidMockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(error: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        sut.perform(request: request, decodeTo: Person.self) { result in
            switch result {
            case .success(let person):
                XCTFail()
            case .failure(let failure):
                XCTAssertTrue(true)
            }
        }
    }
    
    func testPerformWithCompletionHandlerWithNilData() {
        let urlSession = MockURLSession(
            data: nil,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(error: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        sut.perform(request: request, decodeTo: Person.self) { result in
            switch result {
            case .success(let person):
                XCTFail()
            case .failure(let failure):
                XCTAssertTrue(true)
            }
        }
    }
    
    func testPerformWithCompletionHandlerWithNilResponse() {
        let urlSession = MockURLSession(
            data: invalidMockPersonJsonData,
            urlResponse: nil,
            error: nil
        )
        let validator = MockURLResponseValidator(error: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        sut.perform(request: request, decodeTo: Person.self) { result in
            switch result {
            case .success(let person):
                XCTFail()
            case .failure(let failure):
                XCTAssertTrue(true)
            }
        }
    }
    
    // MARK: Unit tests for perform using Completion Handler without Decodable response
    
    func testPerformWithCompletionHandlerWithoutDecodableDoesDecodePerson() {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(error: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        sut.perform(request: request) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure(let failure):
                XCTFail()
            }
        }
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithErrorFails() {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: NetworkingError.forbidden
        )
        let validator = MockURLResponseValidator(error: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        sut.perform(request: request) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(true)
            }
        }
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithBadStatusCodeFails() {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 400),
            error: nil
        )
        let validator = MockURLResponseValidator(error: NetworkingError.badRequest)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        sut.perform(request: request) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(true)
            }
        }
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithNilData() {
        let urlSession = MockURLSession(
            data: nil,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(error: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        sut.perform(request: request) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let failure):
                XCTAssertTrue(true)
            }
        }
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithNilResponse() {
        let urlSession = MockURLSession(
            data: invalidMockPersonJsonData,
            urlResponse: nil,
            error: nil
        )
        let validator = MockURLResponseValidator(error: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformerImpl(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        sut.perform(request: request) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let failure):
                XCTAssertTrue(true)
            }
        }
    }

    
    private func buildResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }

}

class MockURLSession: URLSessionTaskProtocol {
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
    var completion: ((Data?, URLResponse?, Error?) -> Void)?
    
    init(data: Data? = nil, urlResponse: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.completion = completionHandler
        return MockURLSessionDataTask {
            completionHandler(self.data, self.urlResponse, self.error)
        }
    }
    
    func data(for request: URLRequest, delegate: (URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        
        guard let data, let urlResponse else {
            throw NetworkingError.unknown
        }
        return (data, urlResponse)
    }

}

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}

struct MockURLResponseValidator: URLResponseValidator {
    var error: NetworkingError?
    func validate(_ response: URLResponse, withData data: Data) throws {
        guard let error else {
            return
        }
        throw error
    }
}