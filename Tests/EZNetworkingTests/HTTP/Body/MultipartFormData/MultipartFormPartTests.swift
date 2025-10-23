@testable import EZNetworking
import Foundation
import Testing

@Suite("Test MultipartFormPart")
class MultipartFormPartTests {
    
    @Test("explicit MultipartFormPart.file sets all properties")
    func test_MultipartFormPartfile_setsProperties() {
        let payload = "hello".data(using: .utf8)!
        let part = MultipartFormPart.file(name: "field",
                                          data: payload,
                                          filename: "file.txt",
                                          mimeType: .plain)
        
        #expect(part.name == "field")
        #expect(part.filename == "file.txt")
        #expect(part.mimeType == .plain)
        #expect(part.data == payload)
        #expect(part.contentLength == 5)
    }
    
    @Test("explicit MultipartFormPart.string sets all properties")
    func test_MultipartFormPartString_setsProperties() {
        let payload = "value".data(using: .utf8)!
        let part = MultipartFormPart.string(name: "file_name", value: "value")
        
        #expect(part.name == "file_name")
        #expect(part.filename == nil)
        #expect(part.mimeType == .plain)
        #expect(part.data == payload)
        #expect(part.contentLength == 5)
    }

}
