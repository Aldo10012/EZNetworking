import XCTest
@testable import EZNetworking

final class InternalErrorTestsTests: XCTestCase {
 
    func testCouldNotParseIsEquatable() {
        XCTAssertEqual(InternalError.couldNotParse, InternalError.couldNotParse)
    }
    
    func testInvalidErrorIsEquatable() {
        XCTAssertEqual(InternalError.invalidError, InternalError.invalidError)
    }
    
    func testInvalidImageDataIsEquatable() {
        XCTAssertEqual(InternalError.invalidImageData, InternalError.invalidImageData)
    }
    
    func testNoDataIsEquatable() {
        XCTAssertEqual(InternalError.noData, InternalError.noData)
    }
    
    func testNoHTTPURLResponseIsEquatable() {
        XCTAssertEqual(InternalError.noHTTPURLResponse, InternalError.noHTTPURLResponse)
    }
    
    func testNoRequestIsEquatable() {
        XCTAssertEqual(InternalError.noRequest, InternalError.noRequest)
    }
    
    func testNoResponseIsEquatable() {
        XCTAssertEqual(InternalError.noResponse, InternalError.noResponse)
    }
    
    func testNoURLIsEquatable() {
        XCTAssertEqual(InternalError.noURL, InternalError.noURL)
    }
    
    func testRequestFailedIsEquatableWhenErrorIsSame() {
        let error = NetworkingError.httpClientError(.badRequest, [:])
        XCTAssertEqual(InternalError.requestFailed(error), InternalError.requestFailed(error))
    }
    
    func testLostReferenceOfSelfsEquatable() {
        XCTAssertEqual(InternalError.lostReferenceOfSelf, InternalError.lostReferenceOfSelf)
    }
    
    func testUnknownIsEquatable() {
        XCTAssertEqual(InternalError.unknown, InternalError.unknown)
    }
}
