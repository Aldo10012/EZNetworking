@testable import EZNetworking
import Foundation
import Testing

@Suite("Test HTTPBody")
class HTTPBodyTests {

    // MARK: - Test string case
    @Test("test String Success")
    func testStringSuccess() {
        let body = HTTPBody.string("Hello World")
        let data = body.data
        
        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "Hello World")
    }
    
    // MARK: - Test dictionary case
    @Test("test Dictionary Success")
    func testDictionarySuccess() {
        let dictionary: [String: Any] = ["key": "value"]
        let body = HTTPBody.dictionary(dictionary)
        let data = body.data
        
        #expect(data != nil)
        let decoded = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: String]
        #expect(decoded?["key"] == "value")
    }
    
    @Test("test Dictionary Success 2")
    func testDictionarySuccess2() {
        let dictionary: [String: Any] = ["key": ["subKey": "subValue"]]
        let body = HTTPBody.dictionary(dictionary)
        let data = body.data
        
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
        let body = HTTPBody.encodable(encodable)
        let data = body.data
        
        #expect(data != nil)
        let decoded = try? JSONDecoder().decode(TestEncodable.self, from: data!)
        #expect(decoded?.id == 1)
        #expect(decoded?.name == "Test")
    }
    
    // MARK: - Test data case
    @Test("test Data Success")
    func testDataSuccess() {
        let data = Data([0x01, 0x02, 0x03])
        let body = HTTPBody.data(data)
        
        #expect(body.data == data)
    }
    
    @Test("test Data Failure")
    func testDataFailure() {
        let body = HTTPBody.data(Data())
        
        #expect(body.data == Data())
    }
    
    // MARK: - Test fileURL case
    
    @Test("test File URLFailure")
    func testFileURLFailure() {
        let fileURL = URL(fileURLWithPath: "/path/to/non/existing/file")
        let body = HTTPBody.fileURL(fileURL)
        
        #expect(body.data == nil)
    }
    
    // MARK: - Test jsonString case
    @Test("test Json String Success")
    func testJsonStringSuccess() {
        let json = "{\"key\":\"value\"}"
        let body = HTTPBody.jsonString(json)
        
        let data = body.data
        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == json)
    }
    
    @Test("test Json String Failure")
    func testJsonStringFailure() {
        let json = "{\"key\": \"value\""
        let body = HTTPBody.jsonString(json)
        
        #expect(body.data != nil)
    }
    
    // MARK: - Test base64 case
    @Test("test Base64 Success")
    func testBase64Success() {
        let base64String = "SGVsbG8gV29ybGQ="
        let body = HTTPBody.base64(base64String)
        
        let data = body.data
        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "Hello World")
    }
    
    @Test("test Base64 Failure")
    func testBase64Failure() {
        let base64String = "InvalidBase64String"
        let body = HTTPBody.base64(base64String)
        
        #expect(body.data == nil)
    }
    
    @Test("test UrlComponents Success")
    // MARK: - Test urlComponents case
    func testUrlComponentsSuccess() {
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "key", value: "value")]
        
        let body = HTTPBody.urlComponents(components)
        let data = body.data
        
        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "key=value")
    }
    
    @Test("test UrlComponents Failure")
    func testUrlComponentsFailure() {
        var components = URLComponents()
        components.queryItems = nil
        
        let body = HTTPBody.urlComponents(components)
        #expect(body.data == nil)
    }
    
    @Test("test String Equality")
    func testStringEquality() {
        let body1 = HTTPBody.string("testString")
        let body2 = HTTPBody.string("testString")
        let body3 = HTTPBody.string("differentString")
        
        #expect(body1 == body2)
        #expect(body1 != body3)
    }
    
    @Test("test Dictionary Equality")
    func testDictionaryEquality() {
        let dictionary1: [String: Any] = ["key1": "value1", "key2": 2]
        let dictionary2: [String: Any] = ["key1": "value1", "key2": 3]
        
        let body1 = HTTPBody.dictionary(dictionary1)
        let body2 = HTTPBody.dictionary(dictionary2)
        
        #expect(body1 != body2)
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
        
        let body1 = HTTPBody.encodable(encodable1)
        let body2 = HTTPBody.encodable(encodable2)
        let body3 = HTTPBody.encodable(encodable3)
        
        #expect(body1 == body2)
        #expect(body1 != body3)
    }
    
    // Test for .data case
    @Test("test Data Equality")
    func testDataEquality() {
        let data1 = Data([0x01, 0x02, 0x03])
        let data2 = Data([0x01, 0x02, 0x03])
        let data3 = Data([0x01, 0x02, 0x04])
        
        let body1 = HTTPBody.data(data1)
        let body2 = HTTPBody.data(data2)
        let body3 = HTTPBody.data(data3)
        
        #expect(body1 == body2)
        #expect(body1 != body3)
    }
    
    @Test("test Mixed Case Equality")
    func testMixedCaseEquality() {
        let stringBody = HTTPBody.string("testString")
        let dictionaryBody: [String: Any] = ["key": "value"]
        let body1 = HTTPBody.dictionary(dictionaryBody)
        
        #expect(stringBody != body1)
    }
    
    @Test("test Data Equality Nil")
    func testDataEqualityNil() {
        let body1 = HTTPBody.data(Data([0x01, 0x02, 0x03]))
        let body2 = HTTPBody.data(Data([0x01, 0x02, 0x03]))
        
        #expect(body1 == body2)
        let body3 = HTTPBody.data(Data())
        #expect(body1 != body3)
    }
}
