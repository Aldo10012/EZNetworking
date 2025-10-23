@testable import EZNetworking
import Foundation
import Testing

@Suite("Test MultipartFormData")
class MultipartFormDataTests {
    
    // MARK: - Test Constants
    
    @Test("test Constants.crlf")
    func testEncodingCharacters() {
        #expect(MultipartFormData.Constants.crlf == "\r\n")
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
}
