@testable import EZNetworking
import Foundation
import Testing

@Suite("Test MultipartFormData")
class MultipartFormDataTests {
    
    // MARK: - Test EncodingCharacters
    
    @Test("test EncodingCharacters.crlf")
    func testEncodingCharacters() {
        #expect(MultipartFormData.EncodingCharacters.crlf == "\r\n")
    }
    
    // MARK: - Test BoundaryGenerator
    
    @Test("test BoundaryGenerator when BoundaryType is .initial")
    func testBoundaryGenerator_when_BoundaryType_is_Initial() {
        let boudaryData = MultipartFormData.BoundaryGenerator.boundaryData(
            forBoundaryType: .initial, 
            boundary: "SOME_BOUNDARY"
        )
        let boundaryString = String(data: boudaryData, encoding: .utf8)
        #expect(boundaryString == "--SOME_BOUNDARY\r\n")
    }
    
    @Test("test BoundaryGenerator when BoundaryType is .encapsulated")
    func testBoundaryGenerator_when_BoundaryType_is_encapsulated() {
        let boudaryData = MultipartFormData.BoundaryGenerator.boundaryData(
            forBoundaryType: .encapsulated,
            boundary: "SOME_BOUNDARY"
        )
        let boundaryString = String(data: boudaryData, encoding: .utf8)
        #expect(boundaryString == "\r\n--SOME_BOUNDARY\r\n")
    }
    
    @Test("test BoundaryGenerator when BoundaryType is .final")
    func testBoundaryGenerator_when_BoundaryType_is_final() {
        let boudaryData = MultipartFormData.BoundaryGenerator.boundaryData(
            forBoundaryType: .final,
            boundary: "SOME_BOUNDARY"
        )
        let boundaryString = String(data: boudaryData, encoding: .utf8)
        #expect(boundaryString == "\r\n--SOME_BOUNDARY--\r\n")
    }
    
    // MARK: - Test MultipartFormData
    
    @Test("test MultipartFormData - single text part")
    func test_MultipartFormData__single_text_part() {
        let parts: [MultipartFormPart] = [
            MultipartFormPart(name: "username", value: "Daniel")
        ]
        let sut = MultipartFormData(parts: parts, boundary: "SOME_BOUNDARY")
        
        guard let data = sut.data, let decodedString = String(data: data, encoding: .utf8) else {
            Issue.record()
            return
        }
        
        let expectedString = """
        --SOME_BOUNDARY
        Content-Disposition: form-data; name="username"
        Content-Type: text/plain

        Daniel
        --SOME_BOUNDARY--
        
        """
        
        let normalizedDecoded = decodedString.replacingOccurrences(of: "\r\n", with: "\n")
        let normalizedExpected = expectedString.replacingOccurrences(of: "\r\n", with: "\n")
        
        #expect(normalizedDecoded == normalizedExpected)
    }
    
    @Test("test MultipartFormData - multiple text part")
    func test_MultipartFormData__multiple_text_part() {
        let parts: [MultipartFormPart] = [
            MultipartFormPart(name: "username", value: "Daniel"),
            MultipartFormPart(name: "password", value: "******")
        ]
        let sut = MultipartFormData(parts: parts, boundary: "SOME_BOUNDARY")
        
        guard let data = sut.data, let decodedString = String(data: data, encoding: .utf8) else {
            Issue.record()
            return
        }
        
        let expectedString = """
        --SOME_BOUNDARY
        Content-Disposition: form-data; name="username"
        Content-Type: text/plain

        Daniel
        --SOME_BOUNDARY
        Content-Disposition: form-data; name="password"
        Content-Type: text/plain

        ******
        --SOME_BOUNDARY--
        
        """
        
        let normalizedDecoded = decodedString.replacingOccurrences(of: "\r\n", with: "\n")
        let normalizedExpected = expectedString.replacingOccurrences(of: "\r\n", with: "\n")
        
        #expect(normalizedDecoded == normalizedExpected)
    }
    
    @Test("test MultipartFormData - single short .txt file part")
    func test_MultipartFormData__single_short_txt_file_part() {
        let parts: [MultipartFormPart] = [
            MultipartFormPart(name: "user bio",
                              data: Data("Hello World!".utf8),
                              filename: "my_bio.txt",
                              mimeType: .plain)
        ]
        let sut = MultipartFormData(parts: parts, boundary: "SOME_BOUNDARY")
        
        guard let data = sut.data, let decodedString = String(data: data, encoding: .utf8) else {
            Issue.record()
            return
        }
        let expectedString = """
        --SOME_BOUNDARY
        Content-Disposition: form-data; name="user bio"; filename="my_bio.txt"
        Content-Type: text/plain

        Hello World!
        --SOME_BOUNDARY--
        
        """
        
        let normalizedDecoded = decodedString.replacingOccurrences(of: "\r\n", with: "\n")
        let normalizedExpected = expectedString.replacingOccurrences(of: "\r\n", with: "\n")

        #expect(normalizedDecoded == normalizedExpected)
    }
    
    @Test("test MultipartFormData - single longer .txt file part")
    func test_MultipartFormData__single_longer_txt_file_part() {
        let sampleMiniTxtFileContent = """
        Start of document:
        
        This is a mock .txt file that is being uploaded as part of a multipart form. 
        This will simulate what it is like submiting a txt file via multipartform submission.
        """
        let parts: [MultipartFormPart] = [
            MultipartFormPart(name: "description",
                              data: Data(sampleMiniTxtFileContent.utf8),
                              filename: "description.txt",
                              mimeType: .plain)
        ]
        let sut = MultipartFormData(parts: parts, boundary: "SOME_BOUNDARY")
        
        guard let data = sut.data, let decodedString = String(data: data, encoding: .utf8) else {
            Issue.record()
            return
        }
        let expectedString = """
        --SOME_BOUNDARY
        Content-Disposition: form-data; name="description"; filename="description.txt"
        Content-Type: text/plain

        \(sampleMiniTxtFileContent)
        --SOME_BOUNDARY--
        
        """
        
        let normalizedDecoded = decodedString.replacingOccurrences(of: "\r\n", with: "\n")
        let normalizedExpected = expectedString.replacingOccurrences(of: "\r\n", with: "\n")

        #expect(normalizedDecoded == normalizedExpected)
    }
    
    @Test("test MultipartFormData - text part and .txt file part")
    func test_MultipartFormData__text_part_and_txt_file_part() {
        let sampleMiniTxtFileContent = """
        Start of document:
        
        This is a mock .txt file that is being uploaded as part of a multipart form. 
        This will simulate what it is like submiting a txt file via multipartform submission.
        """
        let parts: [MultipartFormPart] = [
            MultipartFormPart(name: "username", value: "Daniel"),
            MultipartFormPart(name: "description",
                              data: Data(sampleMiniTxtFileContent.utf8),
                              filename: "description.txt",
                              mimeType: .plain)
        ]
        let sut = MultipartFormData(parts: parts, boundary: "SOME_BOUNDARY")
        
        guard let data = sut.data, let decodedString = String(data: data, encoding: .utf8) else {
            Issue.record()
            return
        }
        let expectedString = """
        --SOME_BOUNDARY
        Content-Disposition: form-data; name="username"
        Content-Type: text/plain
        
        Daniel
        --SOME_BOUNDARY
        Content-Disposition: form-data; name="description"; filename="description.txt"
        Content-Type: text/plain

        \(sampleMiniTxtFileContent)
        --SOME_BOUNDARY--
        
        """
        
        let normalizedDecoded = decodedString.replacingOccurrences(of: "\r\n", with: "\n")
        let normalizedExpected = expectedString.replacingOccurrences(of: "\r\n", with: "\n")

        #expect(normalizedDecoded == normalizedExpected)
    }
    
}
