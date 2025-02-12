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
}
