import XCTest
@testable import EZNetworking

class HTTPBodyTests: XCTestCase {

    // MARK: - Test string case
    func testStringSuccess() {
        let body = HTTPBody.string("Hello World")
        let data = body.data
        
        XCTAssertNotNil(data)
        XCTAssertEqual(String(data: data!, encoding: .utf8), "Hello World")
    }
    
    // MARK: - Test dictionary case
    func testDictionarySuccess() {
        let dictionary: [String: Any] = ["key": "value"]
        let body = HTTPBody.dictionary(dictionary)
        let data = body.data
        
        XCTAssertNotNil(data)
        let decoded = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: String]
        XCTAssertEqual(decoded?["key"], "value")
    }
    
    func testDictionarySuccess2() {
        let dictionary: [String: Any] = ["key": ["subKey": "subValue"]]
        let body = HTTPBody.dictionary(dictionary)
        let data = body.data
        
        XCTAssertNotNil(data)
        let decoded = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: [String: String]]
        XCTAssertEqual(decoded?["key"], ["subKey": "subValue"])
    }
    
    // MARK: - Test encodable case
    struct TestEncodable: Codable {
        let id: Int
        let name: String
    }
    
    func testEncodableSuccess() {
        let encodable = TestEncodable(id: 1, name: "Test")
        let body = HTTPBody.encodable(encodable)
        let data = body.data
        
        XCTAssertNotNil(data)
        let decoded = try? JSONDecoder().decode(TestEncodable.self, from: data!)
        XCTAssertEqual(decoded?.id, 1)
        XCTAssertEqual(decoded?.name, "Test")
    }
    
    // MARK: - Test data case
    func testDataSuccess() {
        let data = Data([0x01, 0x02, 0x03])
        let body = HTTPBody.data(data)
        
        XCTAssertEqual(body.data, data)
    }
    
    func testDataFailure() {
        let body = HTTPBody.data(Data())
        
        XCTAssertEqual(body.data, Data())
    }
    
    // MARK: - Test fileURL case
    
    func testFileURLFailure() {
        let fileURL = URL(fileURLWithPath: "/path/to/non/existing/file")
        let body = HTTPBody.fileURL(fileURL)
        
        XCTAssertNil(body.data)
    }
    
    // MARK: - Test jsonString case
    func testJsonStringSuccess() {
        let json = "{\"key\":\"value\"}"
        let body = HTTPBody.jsonString(json)
        
        let data = body.data
        XCTAssertNotNil(data)
        XCTAssertEqual(String(data: data!, encoding: .utf8), json)
    }
    
    func testJsonStringFailure() {
        let json = "{\"key\": \"value\""
        let body = HTTPBody.jsonString(json)
        
        XCTAssertNotNil(body.data)
    }
    
    // MARK: - Test base64 case
    func testBase64Success() {
        let base64String = "SGVsbG8gV29ybGQ="
        let body = HTTPBody.base64(base64String)
        
        let data = body.data
        XCTAssertNotNil(data)
        XCTAssertEqual(String(data: data!, encoding: .utf8), "Hello World")
    }
    
    func testBase64Failure() {
        let base64String = "InvalidBase64String"
        let body = HTTPBody.base64(base64String)
        
        XCTAssertNil(body.data)
    }
    
    // MARK: - Test urlComponents case
    func testUrlComponentsSuccess() {
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "key", value: "value")]
        
        let body = HTTPBody.urlComponents(components)
        let data = body.data
        
        XCTAssertNotNil(data)
        XCTAssertEqual(String(data: data!, encoding: .utf8), "key=value")
    }
    
    func testUrlComponentsFailure() {
        var components = URLComponents()
        components.queryItems = nil
        
        let body = HTTPBody.urlComponents(components)
        XCTAssertNil(body.data)
    }
    
    func testStringEquality() {
        let body1 = HTTPBody.string("testString")
        let body2 = HTTPBody.string("testString")
        let body3 = HTTPBody.string("differentString")
        
        XCTAssertTrue(body1 == body2)
        XCTAssertFalse(body1 == body3)
    }
    
    func testDictionaryEquality() {
        let dictionary1: [String: Any] = ["key1": "value1", "key2": 2]
        let dictionary2: [String: Any] = ["key1": "value1", "key2": 3]
        
        let body1 = HTTPBody.dictionary(dictionary1)
        let body2 = HTTPBody.dictionary(dictionary2)
        
        XCTAssertFalse(body1 == body2)
    }
    
    func testEncodableEquality() {
        struct TestEncodable: Codable, Equatable {
            let id: Int
            let name: String
        }
        
        let encodable1 = TestEncodable(id: 1, name: "Test")
        let encodable2 = TestEncodable(id: 1, name: "Test")
        let encodable3 = TestEncodable(id: 2, name: "Test")
        
        let body1 = HTTPBody.encodable(encodable1)
        let body2 = HTTPBody.encodable(encodable2)
        let body3 = HTTPBody.encodable(encodable3)
        
        XCTAssertTrue(body1 == body2)
        XCTAssertFalse(body1 == body3)
    }
    
    // Test for .data case
    func testDataEquality() {
        let data1 = Data([0x01, 0x02, 0x03])
        let data2 = Data([0x01, 0x02, 0x03])
        let data3 = Data([0x01, 0x02, 0x04])
        
        let body1 = HTTPBody.data(data1)
        let body2 = HTTPBody.data(data2)
        let body3 = HTTPBody.data(data3)
        
        XCTAssertTrue(body1 == body2)
        XCTAssertFalse(body1 == body3)
    }
    
    func testMixedCaseEquality() {
        let stringBody = HTTPBody.string("testString")
        let dictionaryBody: [String: Any] = ["key": "value"]
        let body1 = HTTPBody.dictionary(dictionaryBody)
        
        XCTAssertFalse(stringBody == body1)
    }
    
    func testDataEqualityNil() {
        let body1 = HTTPBody.data(Data([0x01, 0x02, 0x03]))
        let body2 = HTTPBody.data(Data([0x01, 0x02, 0x03]))
        
        XCTAssertTrue(body1 == body2)
        let body3 = HTTPBody.data(Data())
        XCTAssertFalse(body1 == body3)
    }
}
