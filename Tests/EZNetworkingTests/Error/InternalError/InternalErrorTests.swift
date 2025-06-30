@testable import EZNetworking
import Testing

@Suite("test InternalError")
final class InternalErrorTests {
 
    @Test("test InternalError.CouldNotParse Is Equatable")
    func testCouldNotParseIsEquatable() {
        #expect(InternalError.couldNotParse == InternalError.couldNotParse)
    }
    
    @Test("test InternalError.invalidError Is Equatable")
    func testInvalidErrorIsEquatable() {
        #expect(InternalError.invalidError == InternalError.invalidError)
    }
    
    @Test("test InternalError.invalidImageData Is Equatable")
    func testInvalidImageDataIsEquatable() {
        #expect(InternalError.invalidImageData == InternalError.invalidImageData)
    }
    
    @Test("test InternalError.noData Is Equatable")
    func testNoDataIsEquatable() {
        #expect(InternalError.noData == InternalError.noData)
    }
    
    @Test("test InternalError.noHTTPURLResponse Is Equatable")
    func testNoHTTPURLResponseIsEquatable() {
        #expect(InternalError.noHTTPURLResponse == InternalError.noHTTPURLResponse)
    }
    
    @Test("test InternalError.noRequest Is Equatable")
    func testNoRequestIsEquatable() {
        #expect(InternalError.noRequest == InternalError.noRequest)
    }
    
    @Test("test InternalError.noResponse Is Equatable")
    func testNoResponseIsEquatable() {
        #expect(InternalError.noResponse == InternalError.noResponse)
    }
    
    @Test("test InternalError.noURL Is Equatable")
    func testNoURLIsEquatable() {
        #expect(InternalError.noURL == InternalError.noURL)
    }
    
    @Test("test InternalError.requestFailed Is Equatable")
    func testRequestFailedIsEquatableWhenErrorIsSame() {
        let error = NetworkingError.httpClientError(.badRequest, [:])
        #expect(InternalError.requestFailed(error) == InternalError.requestFailed(error))
    }
    
    @Test("test InternalError.lostReferenceOfSelf Is Equatable")
    func testLostReferenceOfSelfsEquatable() {
        #expect(InternalError.lostReferenceOfSelf == InternalError.lostReferenceOfSelf)
    }
    
    @Test("test InternalError.unknown Is Equatable")
    func testUnknownIsEquatable() {
        #expect(InternalError.unknown == InternalError.unknown)
    }
}
