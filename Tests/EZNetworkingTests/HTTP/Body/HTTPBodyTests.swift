@testable import EZNetworking
import Foundation
import Testing

@Suite("Test HTTPBody")
class HTTPBodyTests {

    // MARK: - Test string case
    @Test("test String Success")
    func testStringSuccess() {
        let data = HTTPBody(string: "Hello World")
        
        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "Hello World")
    }
    
    // MARK: - Test dictionary case
    @Test("test Dictionary Success")
    func testDictionarySuccess() {
        let dictionary: [String: Any] = ["key": "value"]
        let data = HTTPBody(dictionary: dictionary)
        
        #expect(data != nil)
        let decoded = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: String]
        #expect(decoded?["key"] == "value")
    }
    
    @Test("test Dictionary Success 2")
    func testDictionarySuccess2() {
        let dictionary: [String: Any] = ["key": ["subKey": "subValue"]]
        let data = HTTPBody(dictionary: dictionary)
        
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
        let data = HTTPBody(encodable: encodable)
        
        #expect(data != nil)
        let decoded = try? JSONDecoder().decode(TestEncodable.self, from: data!)
        #expect(decoded?.id == 1)
        #expect(decoded?.name == "Test")
    }
    
    // MARK: - Test fileURL case
    
    @Test("test File URLFailure")
    func testFileURLFailure() {
        let fileURL = URL(fileURLWithPath: "/path/to/non/existing/file")
        let data = HTTPBody(fileURL: fileURL)
        
        #expect(data == nil)
    }
    
    // MARK: - Test jsonString case
    @Test("test Json String Success")
    func testJsonStringSuccess() {
        let json = "{\"key\":\"value\"}"
        let data = HTTPBody(jsonString: json)
        
        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == json)
    }
    
    @Test("test Json String Failure")
    func testJsonStringFailure() {
        let json = "{\"key\": \"value\""
        let data = HTTPBody(jsonString: json)
        
        #expect(data != nil)
    }
    
    // MARK: - Test base64 case
    @Test("test Base64 Success")
    func testBase64Success() {
        let base64String = "SGVsbG8gV29ybGQ="
        let data = HTTPBody(base64: base64String)
        
        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "Hello World")
    }
    
    @Test("test Base64 Failure")
    func testBase64Failure() {
        let base64String = "InvalidBase64String"
        let data = HTTPBody(base64: base64String)
        
        #expect(data == nil)
    }
    
    @Test("test UrlComponents Success")
    // MARK: - Test urlComponents case
    func testUrlComponentsSuccess() {
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "key", value: "value")]
        
        let data = HTTPBody(urlComponents: components)
        
        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "key=value")
    }
    
    @Test("test UrlComponents Failure")
    func testUrlComponentsFailure() {
        var components = URLComponents()
        components.queryItems = nil
        
        let data = HTTPBody(urlComponents: components)
        #expect(data == nil)
    }
    
    @Test("test String Equality")
    func testStringEquality() {
        let data1 = HTTPBody(string: "testString")
        let data2 = HTTPBody(string: "testString")
        let data3 = HTTPBody(string: "differentString")
        
        #expect(data1 == data2)
        #expect(data1 != data3)
    }
    
    @Test("test Dictionary Equality")
    func testDictionaryEquality() {
        let dictionary1: [String: Any] = ["key1": "value1", "key2": 2]
        let dictionary2: [String: Any] = ["key1": "value1", "key2": 3]
        
        let data1 = HTTPBody(dictionary: dictionary1)
        let data2 = HTTPBody(dictionary: dictionary2)
        
        #expect(data1 != data2)
    }
    
    @Test("test Encodable Equality")
    func testEncodableEquality() {
        let encodable1 = TestEncodable(id: 1, name: "Test")
        let encodable2 = TestEncodable(id: 1, name: "Test")
        
        let data1 = HTTPBody(encodable: encodable1)
        let data2 = HTTPBody(encodable: encodable2)
        
        #expect(data1 == data2)
    }
    
    @Test("test Encodable not Equal when different")
    func testEncodableNonEquality() {
        let encodable1 = TestEncodable(id: 1, name: "Test")
        let encodable2 = TestEncodable(id: 2, name: "test")
        
        let data1 = HTTPBody(encodable: encodable1)
        let data2 = HTTPBody(encodable: encodable2)
        
        #expect(data1 != data2)
    }
    
    @Test("test Mixed Case Equality")
    func testMixedCaseEquality() {
        let stringBody = HTTPBody(string: "testString")
        let dictionaryBody: [String: Any] = ["key": "value"]
        let data1 = HTTPBody(dictionary: dictionaryBody)
        
        #expect(stringBody != data1)
    }
    
    // MARK: Test .appending()
    
    @Test("test .appending(_:) is chainable and returns concatenated data")
    func test_appending_chainable_concatenates() {
        let result = HTTPBody()
            .appending(HTTPBody(string: "A"))
            .appending(HTTPBody(string: "B"))
            .appending(HTTPBody(string: "C"))
        
        #expect(String(data: result, encoding: .utf8) == "ABC")
    }
    
    @Test("test .appending(nil) returns original unchanged")
    func test_appending_nil_returnsSame() {
        let original = HTTPBody(string: "X")!
        let appended = original.appending(nil)
        
        #expect(appended == original)
    }
    
    @Test("test .appending(_) does not mutate the original Data (non-mutating API)")
    func test_appending_doesNotMutateOriginal() {
        let original = HTTPBody(string: "orig")!
        let copyBefore = original
        _ = original.appending(HTTPBody(string: "more"))
        // original should remain equal to the copy made before calling appending(_:)
        #expect(original == copyBefore)
    }
    
    @Test("test .appending(empty Data) returns concatenated result equal to original + empty")
    func test_appending_emptyData_behavesCorrectly() {
        let original = HTTPBody(string: "Y")!
        let empty = Data()
        let result = original.appending(empty)
        
        #expect(result == original) // concatenating empty should yield the same bytes
    }
}
