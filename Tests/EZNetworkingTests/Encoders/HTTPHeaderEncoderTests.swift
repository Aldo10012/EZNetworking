//
//  HTTPHeaderEncoderTests.swift
//  
//
//  Created by Alberto Dominguez on 7/14/24.
//

import XCTest
@testable import EZNetworking

final class HTTPHeaderEncoderTests: XCTestCase {
    
    func testURLRequestAllHTTPHeaderFieldsIsSetToInjectedHeaders() throws {
        let sut = HTTPHeaderEncoderImpl()
        let url = try XCTUnwrap(URL(string: "https://www.example.com"))
        var urlRequest = URLRequest(url: url)
        
        sut.encodeHeaders(for: &urlRequest, with: [
            .accept(.json),
            .contentType(.json),
            .authorization(.bearer("My_API_KEY"))
        ])
        
        let expextedHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer My_API_KEY"
        ]
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, expextedHeaders)
    }
}
