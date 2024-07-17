//
//  URLResponseValidatorTests.swift
//
//
//  Created by Alberto Dominguez on 7/14/24.
//

import XCTest
@testable import EZNetworking

final class URLResponseValidatorTests: XCTestCase {
    
    func testValidateOKResponse() {
        let validator = URLResponseValidatorImpl()
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!

        do {
            try validator.validate(data: Data(), urlResponse: response, error: nil)
            XCTAssert(true)
        } catch {
            XCTFail("Unexpected error)")
        }
    }
    
    func testValidateErrorResponse() throws {
        let validator = URLResponseValidatorImpl()
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        
        do {
            try validator.validate(data: Data(), urlResponse: response, error: nil)
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.notFound)
        }
    }
    
    func testValidateNonHTTPURLResponse() throws {
        let validator = URLResponseValidatorImpl()
        let response = URLResponse(url: URL(string: "https://example.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        
        do {
            try validator.validate(data: Data(), urlResponse: response, error: nil)
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.noHTTPURLResponse)
        }
    }
    
    func testValidateFailsWhenDataIsNil() throws {
        let validator = URLResponseValidatorImpl()
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        do {
            try validator.validate(data: nil, urlResponse: response, error: nil)
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.noData)
        }
    }
    
    func testValidateFailsWhenURLResponseIsNil() throws {
        let validator = URLResponseValidatorImpl()
        do {
            try validator.validate(data: Data(), urlResponse: nil, error: nil)
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.noResponse)
        }
    }
    
    func testValidateFailsWhenErrorIsNotNil() throws {
        let validator = URLResponseValidatorImpl()
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        do {
            try validator.validate(data: Data(), urlResponse: response, error: NetworkingError.badGateway)
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.requestFailed(NetworkingError.badGateway))
        }
    }
    
}
