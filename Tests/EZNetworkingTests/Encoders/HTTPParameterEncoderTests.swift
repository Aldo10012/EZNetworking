//
//  HTTPParameterEncoderTests.swift
//  
//
//  Created by Alberto Dominguez on 7/14/24.
//

import XCTest
@testable import EZNetworking

final class HTTPParameterEncoderTests: XCTestCase {

    func testURLQueryParametersAreAdded() throws {
        let sut = HTTPParameterEncoderImpl()
        let url = try XCTUnwrap(URL(string: "https://www.example.com"))
        var urlRequest = URLRequest(url: url)
        
        
        try sut.encodeParameters(for: &urlRequest, with: [
            HTTPParameter(key: "key_1", value: "value_1"),
            HTTPParameter(key: "key_2", value: "value_2"),
            HTTPParameter(key: "key_3", value: "value_3")
        ])
        
        let expectedURL = "https://www.example.com?key_1=value_1&key_2=value_2&key_3=value_3"
        XCTAssertEqual(urlRequest.url?.absoluteString, expectedURL)
    }

}
