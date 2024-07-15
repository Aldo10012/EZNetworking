//
//  HTTPParameterTests.swift
//  
//
//  Created by Alberto Dominguez on 7/14/24.
//

import XCTest
@testable import EZNetworking

final class HTTPParameterTests: XCTestCase {
    
    func testInitialization() {
        let key = "param_key"
        let value = "param_value"
        let parameter = HTTPParameter(key: key, value: value)
        
        XCTAssertEqual(parameter.key, key)
        XCTAssertEqual(parameter.value, value)
    }
    
}
