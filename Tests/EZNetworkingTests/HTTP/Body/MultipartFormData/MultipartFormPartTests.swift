@testable import EZNetworking
import Foundation
import Testing

@Suite("Test MultipartFormPart")
class MultipartFormPartTests {
    @Test("explicit MultipartFormPart.file sets all properties")
    func MultipartFormPartfile_setsProperties() {
        let payload = "hello".data(using: .utf8)!
        let part = MultipartFormPart.filePart(
            name: "field",
            data: payload,
            filename: "file.txt",
            mimeType: .plain
        )

        #expect(part.name == "field")
        #expect(part.filename == "file.txt")
        #expect(part.mimeType == .plain)
        #expect(part.data == payload)
        #expect(part.contentLength == 5)
    }

    @Test("explicit MultipartFormPart.string sets all properties")
    func MultipartFormPartString_setsProperties() {
        let payload = "value".data(using: .utf8)!
        let part = MultipartFormPart.fieldPart(name: "file", value: "value")

        #expect(part.name == "file")
        #expect(part.filename == nil)
        #expect(part.mimeType == .plain)
        #expect(part.data == payload)
        #expect(part.contentLength == 5)
    }

    @Test("explicit MultipartFormPart.dataPart sets all properties")
    func MultipartFormPartData_setsProperties() {
        let payload = "value".data(using: .utf8)!
        let part = MultipartFormPart.dataPart(
            name: "field",
            data: payload,
            mimeType: .json
        )
        #expect(part.name == "field")
        #expect(part.filename == nil)
        #expect(part.mimeType == .json)
        #expect(part.data == payload)
        #expect(part.contentLength == 5)
    }
}
