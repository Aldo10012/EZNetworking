@testable import EZNetworking
import Foundation
import Testing

@Suite("Test MultipartFormPart")
class MultipartFormPartTests {
    
    @Test("explicit initializer sets all properties")
    func test_explicitInitializer_setsProperties() {
        let payload = "hello".data(using: .utf8)!
        let part = MultipartFormPart(name: "field",
                                     data: payload,
                                     filename: "file.txt",
                                     mimeType: .plain)
        
        #expect(part.name == "field")
        #expect(part.filename == "file.txt")
        #expect(part.mimeType == .plain)
        #expect(part.data == payload)
        #expect(part.contentLength == 5)
    }
    
    @Test("test text Field initializer")
    func test_textField_initializer() {
        let payload = "value".data(using: .utf8)!
        let part = MultipartFormPart(name: "file_name", value: "value")
        
        #expect(part.name == "file_name")
        #expect(part.filename == nil)
        #expect(part.mimeType == .plain)
        #expect(part.data == payload)
        #expect(part.contentLength == 5)
    }

}
