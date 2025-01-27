import XCTest
@testable import EZNetworking

final class HTTPServerStatusTests: XCTestCase {
    
    func testStatusCode500IsInternalServerError() {
        XCTAssertEqual(HTTPServerStatus(statusCode: 500), .internalServerError)
    }
    
    func testStatusCode501IsNotImplemented() {
        XCTAssertEqual(HTTPServerStatus(statusCode: 501), .notImplemented)
    }
    
    func testStatusCode502IsBadGateway() {
        XCTAssertEqual(HTTPServerStatus(statusCode: 502), .badGateway)
    }
    
    func testStatusCode503IsServiceUnavailable() {
        XCTAssertEqual(HTTPServerStatus(statusCode: 503), .serviceUnavailable)
    }
    
    func testStatusCode504IsGatewayTimeout() {
        XCTAssertEqual(HTTPServerStatus(statusCode: 504), .gatewayTimeout)
    }
    
    func testStatusCode505IsHttpVersionNotSupported() {
        XCTAssertEqual(HTTPServerStatus(statusCode: 505), .httpVersionNotSupported)
    }
    
    func testStatusCode506IsVariantAlsoNegotiates() {
        XCTAssertEqual(HTTPServerStatus(statusCode: 506), .variantAlsoNegotiates)
    }
    
    func testStatusCode507IsInsufficientStorage() {
        XCTAssertEqual(HTTPServerStatus(statusCode: 507), .insufficientStorage)
    }
    
    func testStatusCode508IsLoopDetected() {
        XCTAssertEqual(HTTPServerStatus(statusCode: 508), .loopDetected)
    }
    
    func testStatusCode510IsNotExtended() {
        XCTAssertEqual(HTTPServerStatus(statusCode: 510), .notExtended)
    }
    
    func testStatusCode511IsNetworkAuthenticationRequired() {
        XCTAssertEqual(HTTPServerStatus(statusCode: 511), .networkAuthenticationRequired)
    }
    
    func testStatusCode511IsUnknown() {
        XCTAssertEqual(HTTPServerStatus(statusCode: 512), .unknown)
    }
    
    func testDifferentHTTPNetworkingServerErrorsAreNotEquatable() {
        XCTAssertNotEqual(HTTPServerStatus.badGateway, HTTPServerStatus.gatewayTimeout)
    }
}
