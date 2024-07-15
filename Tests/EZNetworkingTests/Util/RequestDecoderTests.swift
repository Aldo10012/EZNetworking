//
//  RequestDecoderTests.swift
//  
//
//  Created by Alberto Dominguez on 7/14/24.
//

import XCTest
@testable import EZNetworking

final class RequestDecoderTests: XCTestCase {

    func testDocoderCanDocodeMockJSONIntoDeocdableObject() throws {
        let sut = RequestDecoder()
        do {
            let person = try sut.decode(Person.self, from: mockPersonJsonData)
            XCTAssertEqual(person.name, "John")
            XCTAssertEqual(person.age, 30)
        } catch {
            XCTFail("Unexpected error)")
        }
    }
    
    func testDocoderCanNotDocodeInvalidMockJSONIntoDeocdableObject() throws {
        let sut = RequestDecoder()
        do {
            let person = try sut.decode(Person.self, from: invalidMockPersonJsonData)
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.couldNotParse)
        }
    }

}

// TODO: move to a dedicated Mock file
struct Person: Decodable {
    var name: String
    var age: Int
}

let mockPersonJsonData = """
{
    "name": "John",
    "age": 30
}
""".data(using: .utf8)!

let invalidMockPersonJsonData = """
{
    "Name": "John",
    "Age": 30
}
""".data(using: .utf8)!
