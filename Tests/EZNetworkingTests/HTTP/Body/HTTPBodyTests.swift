@testable import EZNetworking
import Foundation
import Testing

@Suite("Test HTTPBody")
class HTTPBodyTests {

    // MARK: - Test string case
    @Test("test String Success")
    func testStringSuccess() {
        let data = HTTPBody.fromString("Hello World")
        
        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "Hello World")
    }
    
    // MARK: - Test dictionary case
    @Test("test Dictionary Success")
    func testDictionarySuccess() {
        let dictionary: [String: Any] = ["key": "value"]
        let data = HTTPBody.fromDictionary(dictionary)
        
        #expect(data != nil)
        let decoded = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: String]
        #expect(decoded?["key"] == "value")
    }
    
    @Test("test Dictionary Success 2")
    func testDictionarySuccess2() {
        let dictionary: [String: Any] = ["key": ["subKey": "subValue"]]
        let data = HTTPBody.fromDictionary(dictionary)
        
        #expect(data != nil)
        let decoded = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: [String: String]]
        #expect(decoded?["key"] == ["subKey": "subValue"])
    }
    
    // MARK: - Test encodable case
    struct TestEncodable: Codable {
        let id: Int
        let name: String
    }
    
    @Test("test Encodable Success")
    func testEncodableSuccess() {
        let encodable = TestEncodable(id: 1, name: "Test")
        let data = HTTPBody.fromEncodable(encodable)
        
        #expect(data != nil)
        let decoded = try? JSONDecoder().decode(TestEncodable.self, from: data!)
        #expect(decoded?.id == 1)
        #expect(decoded?.name == "Test")
    }
    
    // MARK: - Test fileURL case
    
    @Test("test File URLFailure")
    func testFileURLFailure() {
        let fileURL = URL(fileURLWithPath: "/path/to/non/existing/file")
        let data = HTTPBody.fromFileURL(fileURL)
        
        #expect(data == nil)
    }
    
    // MARK: - Test jsonString case
    @Test("test Json String Success")
    func testJsonStringSuccess() {
        let json = "{\"key\":\"value\"}"
        let data = HTTPBody.fromJsonString(json)
        
        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == json)
    }
    
    @Test("test Json String Failure")
    func testJsonStringFailure() {
        let json = "{\"key\": \"value\""
        let data = HTTPBody.fromJsonString(json)
        
        #expect(data != nil)
    }
    
    // MARK: - Test base64 case
    @Test("test Base64 Success")
    func testBase64Success() {
        let base64String = "SGVsbG8gV29ybGQ="
        let data = HTTPBody.fromBase64(base64String)
        
        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "Hello World")
    }
    
    @Test("test Base64 Failure")
    func testBase64Failure() {
        let base64String = "InvalidBase64String"
        let data = HTTPBody.fromBase64(base64String)
        
        #expect(data == nil)
    }
    
    @Test("test UrlComponents Success")
    // MARK: - Test urlComponents case
    func testUrlComponentsSuccess() {
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "key", value: "value")]
        
        let data = HTTPBody.fromURLComponents(components)
        
        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "key=value")
    }
    
    @Test("test UrlComponents Failure")
    func testUrlComponentsFailure() {
        var components = URLComponents()
        components.queryItems = nil
        
        let data = HTTPBody.fromURLComponents(components)
        #expect(data == nil)
    }
    
    @Test("test String Equality")
    func testStringEquality() {
        let data1 = HTTPBody.fromString("testString")
        let data2 = HTTPBody.fromString("testString")
        let data3 = HTTPBody.fromString("differentString")
        
        #expect(data1 == data2)
        #expect(data1 != data3)
    }
    
    @Test("test Dictionary Equality")
    func testDictionaryEquality() {
        let dictionary1: [String: Any] = ["key1": "value1", "key2": 2]
        let dictionary2: [String: Any] = ["key1": "value1", "key2": 3]
        
        let data1 = HTTPBody.fromDictionary(dictionary1)
        let data2 = HTTPBody.fromDictionary(dictionary2)
        
        #expect(data1 != data2)
    }
    
    @Test("test Encodable Equality")
    func testEncodableEquality() {
        struct TestEncodable: Codable, Equatable {
            let id: Int
            let name: String
        }
        
        let encodable1 = TestEncodable(id: 1, name: "Test")
        let encodable2 = TestEncodable(id: 1, name: "Test")
        let encodable3 = TestEncodable(id: 2, name: "Test")
        
        let data1 = HTTPBody.fromEncodable(encodable1)
        let data2 = HTTPBody.fromEncodable(encodable2)
        let data3 = HTTPBody.fromEncodable(encodable3)
        
        #expect(data1 == data2)
        #expect(data1 != data3)
    }
    
    @Test("test Mixed Case Equality")
    func testMixedCaseEquality() {
        let stringBody = HTTPBody.fromString("testString")
        let dictionaryBody: [String: Any] = ["key": "value"]
        let data1 = HTTPBody.fromDictionary(dictionaryBody)
        
        #expect(stringBody != data1)
    }
    
}
