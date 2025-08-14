@testable import EZNetworking
import Foundation
import Testing

@Suite("Test MultipartBodyBuilder")
final class MultipartBodyBuilderTests {

    @Test("test MultipartBodyContainsBoundaryAndHeaders")
    func testMultipartBodyContainsBoundaryAndHeaders() {
        let boundary = "Boundary-123"
        let fileName = "test.txt"
        let mimeType = "text/plain"
        let fileContent = "Hello, world!"
        let fileData = fileContent.data(using: .utf8)!
        
        let body = MultipartBodyBuilder.createMultipartBody(
            boundary: boundary,
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType
        )
        
        guard let bodyString = String(data: body, encoding: .utf8) else {
            Issue.record("Could not convert body to string")
            return
        }
        
        #expect(true == bodyString.contains("--\(boundary)\r\n"))
        #expect(true == bodyString.contains("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\""))
        #expect(true == bodyString.contains("Content-Type: \(mimeType)\r\n\r\n"))
        #expect(true == bodyString.contains(fileContent))
        #expect(true == bodyString.contains("--\(boundary)--\r\n"))
    }

}

@Suite("Test MimeType")
final class MimeTypeTests {

    @Test("test MimeType mapping")
    func testMimeTypeMapping() {
        #expect(MimeType.mimeType(for: "jpg") == "image/jpeg")
        #expect(MimeType.mimeType(for: "jpeg") == "image/jpeg")
        #expect(MimeType.mimeType(for: "png") == "image/png")
        #expect(MimeType.mimeType(for: "pdf") == "application/pdf")
        #expect(MimeType.mimeType(for: "txt") == "text/plain")
        #expect(MimeType.mimeType(for: "mp4") == "video/mp4")
        #expect(MimeType.mimeType(for: "mov") == "video/quicktime")
        #expect(MimeType.mimeType(for: "json") == "application/json")
        #expect(MimeType.mimeType(for: "foo") == "application/octet-stream")
    }

}

