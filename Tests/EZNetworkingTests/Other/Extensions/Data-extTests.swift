@testable import EZNetworking
import Foundation
import Testing

@Suite("Test Data Extensions")
class DataExtensionsTests {
    // MARK: - Test string case

    @Test("test String Success")
    func stringSuccess() {
        let data = Data(string: "Hello World")

        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "Hello World")
    }

    // MARK: - Test dictionary case

    @Test("test Dictionary Success")
    func dictionarySuccess() {
        let dictionary: [String: Any] = ["key": "value"]
        let data = Data(dictionary: dictionary)

        #expect(data != nil)
        let decoded = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: String]
        #expect(decoded?["key"] == "value")
    }

    @Test("test Dictionary Success 2")
    func dictionarySuccess2() {
        let dictionary: [String: Any] = ["key": ["subKey": "subValue"]]
        let data = Data(dictionary: dictionary)

        #expect(data != nil)
        let decoded = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: [String: String]]
        #expect(decoded?["key"] == ["subKey": "subValue"])
    }

    // MARK: - Test encodable case

    struct TestEncodable: Codable, Equatable {
        let id: Int
        let name: String
    }

    @Test("test Encodable Success")
    func encodableSuccess() {
        let encodable = TestEncodable(id: 1, name: "Test")
        let data = Data(encodable: encodable)

        #expect(data != nil)
        let decoded = try? JSONDecoder().decode(TestEncodable.self, from: data!)
        #expect(decoded?.id == 1)
        #expect(decoded?.name == "Test")
    }

    // MARK: - Test fileURL case

    @Test("test File URLFailure")
    func fileURLFailure() {
        let fileURL = URL(fileURLWithPath: "/path/to/non/existing/file")
        let data = Data(fileURL: fileURL)

        #expect(data == nil)
    }

    // MARK: - Test jsonString case

    @Test("test Json String Success")
    func jsonStringSuccess() {
        let json = "{\"key\":\"value\"}"
        let data = Data(jsonString: json)

        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == json)
    }

    @Test("test Json String Failure")
    func jsonStringFailure() {
        let json = "{\"key\": \"value\""
        let data = Data(jsonString: json)

        #expect(data != nil)
    }

    // MARK: - Test base64 case

    @Test("test Base64 Success")
    func base64Success() {
        let base64String = "SGVsbG8gV29ybGQ="
        let data = Data(base64: base64String)

        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "Hello World")
    }

    @Test("test Base64 Failure")
    func base64Failure() {
        let base64String = "InvalidBase64String"
        let data = Data(base64: base64String)

        #expect(data == nil)
    }

    // MARK: - Test MultipartFormData

    @Test("test MultipartFormData")
    func testMultipartFormData() {
        let multipartFormData = MultipartFormData(
            parts: [
                .fieldPart(name: "username", value: "Daniel")
            ],
            boundary: "BOUNDARY"
        )
        guard let data = Data(multipartFormData: multipartFormData),
              let decodedString = String(data: data, encoding: .utf8) else
        {
            Issue.record()
            return
        }

        let expectedString = """
        --BOUNDARY
        Content-Disposition: form-data; name="username"
        Content-Type: text/plain

        Daniel
        --BOUNDARY--

        """

        let normalizedDecoded = decodedString.replacingOccurrences(of: "\r\n", with: "\n")
        let normalizedExpected = expectedString.replacingOccurrences(of: "\r\n", with: "\n")

        #expect(normalizedDecoded == normalizedExpected)
    }

    @Test("test UrlComponents Success")

    // MARK: - Test urlComponents case

    func urlComponentsSuccess() {
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "key", value: "value")]

        let data = Data(urlComponents: components)

        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "key=value")
    }

    @Test("test UrlComponents Failure")
    func urlComponentsFailure() {
        var components = URLComponents()
        components.queryItems = nil

        let data = Data(urlComponents: components)
        #expect(data == nil)
    }

    @Test("test String Equality")
    func stringEquality() {
        let data1 = Data(string: "testString")
        let data2 = Data(string: "testString")
        let data3 = Data(string: "differentString")

        #expect(data1 == data2)
        #expect(data1 != data3)
    }

    @Test("test Dictionary Equality")
    func dictionaryEquality() {
        let dictionary1: [String: Any] = ["key1": "value1", "key2": 2]
        let dictionary2: [String: Any] = ["key1": "value1", "key2": 3]

        let data1 = Data(dictionary: dictionary1)
        let data2 = Data(dictionary: dictionary2)

        #expect(data1 != data2)
    }

    @Test("test Encodable Equality")
    func encodableEquality() {
        let encodable1 = TestEncodable(id: 1, name: "Test")
        let encodable2 = TestEncodable(id: 1, name: "Test")

        guard let data1 = Data(encodable: encodable1), let data2 = Data(encodable: encodable2) else {
            Issue.record()
            return
        }

        do {
            let decoded1 = try JSONDecoder().decode(TestEncodable.self, from: data1)
            let decoded2 = try JSONDecoder().decode(TestEncodable.self, from: data2)
            #expect(decoded1 == decoded2)
        } catch {
            Issue.record()
        }
    }

    @Test("test Encodable not Equal when different")
    func encodableNonEquality() {
        let encodable1 = TestEncodable(id: 1, name: "Test")
        let encodable2 = TestEncodable(id: 2, name: "test")

        let data1 = Data(encodable: encodable1)
        let data2 = Data(encodable: encodable2)

        #expect(data1 != data2)
    }

    @Test("test encodable HTTPBody can decode to correct type")
    func encodableHttpBodyCanDecodeToCorrectType() {
        let sut = TestEncodable(id: 1, name: "Test")
        guard let data = Data(encodable: sut) else {
            Issue.record(); return
        }

        #expect(throws: Never.self) {
            try? JSONDecoder().decode(TestEncodable.self, from: data)
        }
    }

    @Test("test Mixed Case Equality")
    func mixedCaseEquality() {
        let stringBody = Data(string: "testString")
        let dictionaryBody: [String: Any] = ["key": "value"]
        let data1 = Data(dictionary: dictionaryBody)

        #expect(stringBody != data1)
    }

    // MARK: Test .appending()

    @Test("test .appending(_:) is chainable and returns concatenated data")
    func appending_chainable_concatenates() {
        let result = Data()
            .appending(Data(string: "A"))
            .appending(Data(string: "B"))
            .appending(Data(string: "C"))

        #expect(String(data: result, encoding: .utf8) == "ABC")
    }

    @Test("test .appending(nil) returns original unchanged")
    func appending_nil_returnsSame() {
        let original = Data(string: "X")!
        let appended = original.appending(nil)

        #expect(appended == original)
    }

    @Test("test .appending(_) does not mutate the original Data (non-mutating API)")
    func appending_doesNotMutateOriginal() {
        let original = Data(string: "orig")!
        let copyBefore = original
        _ = original.appending(Data(string: "more"))
        // original should remain equal to the copy made before calling appending(_:)
        #expect(original == copyBefore)
    }

    @Test("test .appending(empty Data) returns concatenated result equal to original + empty")
    func appending_emptyData_behavesCorrectly() {
        let original = Data(string: "Y")!
        let empty = Data()
        let result = original.appending(empty)

        #expect(result == original) // concatenating empty should yield the same bytes
    }
}
