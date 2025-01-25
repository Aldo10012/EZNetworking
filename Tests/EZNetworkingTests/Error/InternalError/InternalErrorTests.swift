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
        let error = NetworkingError.httpClientError(.badRequest)
        XCTAssertEqual(InternalError.requestFailed(error), InternalError.requestFailed(error))
    }
    
    func testRequestFailedIsNotEquatableWhenErrorIsNotSame() {
        let error1 = NetworkingError.httpClientError(.badRequest)
        let error2 = NetworkingError.httpClientError(.forbidden)
        XCTAssertNotEqual(InternalError.requestFailed(error1), InternalError.requestFailed(error2))
    }
    
    func testUnknownIsEquatable() {
        XCTAssertEqual(InternalError.unknown, InternalError.unknown)
    }
}
