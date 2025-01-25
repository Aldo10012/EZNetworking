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
            _ = try sut.decode(Person.self, from: invalidMockPersonJsonData)
            XCTFail("Unexpected error)")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, NetworkingError.internalError(.couldNotParse))
        }
    }

}
