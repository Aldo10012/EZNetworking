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
            try validator.validate(response, withData: Data())
            XCTAssert(true)
        } catch {
            XCTFail("Unexpected error)")
        }
    }
    
    func testValidateErrorResponse() throws {
        let validator = URLResponseValidatorImpl()
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        
        do {
            try validator.validate(response, withData: Data())
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.notFound)
        }
    }
    
    func testValidateNonHTTPURLResponse() throws {
        let validator = URLResponseValidatorImpl()
        let response = URLResponse(url: URL(string: "https://example.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        
        do {
            try validator.validate(response, withData: Data())
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.noHTTPURLResponse)
        }
    }
    
}
