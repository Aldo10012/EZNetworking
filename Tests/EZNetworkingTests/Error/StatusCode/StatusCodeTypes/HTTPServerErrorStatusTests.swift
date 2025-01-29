import XCTest
@testable import EZNetworking

final class HTTPServerErrorStatusTests: XCTestCase {
    
    func testStatusCode500IsInternalServerError() {
        XCTAssertEqual(HTTPServerErrorStatus(statusCode: 500), .internalServerError)
    }
    
    func testStatusCode501IsNotImplemented() {
        XCTAssertEqual(HTTPServerErrorStatus(statusCode: 501), .notImplemented)
    }
    
    func testStatusCode502IsBadGateway() {
        XCTAssertEqual(HTTPServerErrorStatus(statusCode: 502), .badGateway)
    }
    
    func testStatusCode503IsServiceUnavailable() {
        XCTAssertEqual(HTTPServerErrorStatus(statusCode: 503), .serviceUnavailable)
    }
    
    func testStatusCode504IsGatewayTimeout() {
        XCTAssertEqual(HTTPServerErrorStatus(statusCode: 504), .gatewayTimeout)
    }
    
    func testStatusCode505IsHttpVersionNotSupported() {
        XCTAssertEqual(HTTPServerErrorStatus(statusCode: 505), .httpVersionNotSupported)
    }
    
    func testStatusCode506IsVariantAlsoNegotiates() {
        XCTAssertEqual(HTTPServerErrorStatus(statusCode: 506), .variantAlsoNegotiates)
    }
    
    func testStatusCode507IsInsufficientStorage() {
        XCTAssertEqual(HTTPServerErrorStatus(statusCode: 507), .insufficientStorage)
    }
    
    func testStatusCode508IsLoopDetected() {
        XCTAssertEqual(HTTPServerErrorStatus(statusCode: 508), .loopDetected)
    }
    
    func testStatusCode510IsNotExtended() {
        XCTAssertEqual(HTTPServerErrorStatus(statusCode: 510), .notExtended)
    }
    
    func testStatusCode511IsNetworkAuthenticationRequired() {
        XCTAssertEqual(HTTPServerErrorStatus(statusCode: 511), .networkAuthenticationRequired)
    }
    
    func testStatusCode511IsUnknown() {
        XCTAssertEqual(HTTPServerErrorStatus(statusCode: 512), .unknown)
    }
    
    func testDifferentHTTPNetworkingServerErrorsAreNotEquatable() {
        XCTAssertNotEqual(HTTPServerErrorStatus.badGateway, HTTPServerErrorStatus.gatewayTimeout)
    }
}
