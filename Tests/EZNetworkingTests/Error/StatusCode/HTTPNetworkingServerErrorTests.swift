import XCTest
@testable import EZNetworking

final class HTTPNetworkingServerErrorTests: XCTestCase {
    
    func testStatusCode500IsInternalServerError() {
        XCTAssertEqual(HTTPNetworkingServerError(statusCode: 500), .internalServerError)
    }
    
    func testStatusCode501IsNotImplemented() {
        XCTAssertEqual(HTTPNetworkingServerError(statusCode: 501), .notImplemented)
    }
    
    func testStatusCode502IsBadGateway() {
        XCTAssertEqual(HTTPNetworkingServerError(statusCode: 502), .badGateway)
    }
    
    func testStatusCode503IsServiceUnavailable() {
        XCTAssertEqual(HTTPNetworkingServerError(statusCode: 503), .serviceUnavailable)
    }
    
    func testStatusCode504IsGatewayTimeout() {
        XCTAssertEqual(HTTPNetworkingServerError(statusCode: 504), .gatewayTimeout)
    }
    
    func testStatusCode505IsHttpVersionNotSupported() {
        XCTAssertEqual(HTTPNetworkingServerError(statusCode: 505), .httpVersionNotSupported)
    }
    
    func testStatusCode506IsVariantAlsoNegotiates() {
        XCTAssertEqual(HTTPNetworkingServerError(statusCode: 506), .variantAlsoNegotiates)
    }
    
    func testStatusCode507IsInsufficientStorage() {
        XCTAssertEqual(HTTPNetworkingServerError(statusCode: 507), .insufficientStorage)
    }
    
    func testStatusCode508IsLoopDetected() {
        XCTAssertEqual(HTTPNetworkingServerError(statusCode: 508), .loopDetected)
    }
    
    func testStatusCode510IsNotExtended() {
        XCTAssertEqual(HTTPNetworkingServerError(statusCode: 510), .notExtended)
    }
    
    func testStatusCode511IsNetworkAuthenticationRequired() {
        XCTAssertEqual(HTTPNetworkingServerError(statusCode: 511), .networkAuthenticationRequired)
    }
    
    func testStatusCode511IsUnknown() {
        XCTAssertEqual(HTTPNetworkingServerError(statusCode: 512), .unknown)
    }
    
    func testDifferentHTTPNetworkingServerErrorsAreNotEquatable() {
        XCTAssertNotEqual(HTTPNetworkingServerError.badGateway, HTTPNetworkingServerError.gatewayTimeout)
    }
}
