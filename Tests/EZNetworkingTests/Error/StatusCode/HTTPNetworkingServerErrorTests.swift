import XCTest
@testable import EZNetworking

final class HTTPNetworkingServerErrorTests: XCTestCase {
    
    func testStatusCode500IsInternalServerError() {
        XCTAssertEqual(HTTPNetworkingServerError.fromStatusCode(500), .internalServerError)
    }
    
    func testStatusCode501IsNotImplemented() {
        XCTAssertEqual(HTTPNetworkingServerError.fromStatusCode(501), .notImplemented)
    }
    
    func testStatusCode502IsBadGateway() {
        XCTAssertEqual(HTTPNetworkingServerError.fromStatusCode(502), .badGateway)
    }
    
    func testStatusCode503IsServiceUnavailable() {
        XCTAssertEqual(HTTPNetworkingServerError.fromStatusCode(503), .serviceUnavailable)
    }
    
    func testStatusCode504IsGatewayTimeout() {
        XCTAssertEqual(HTTPNetworkingServerError.fromStatusCode(504), .gatewayTimeout)
    }
    
    func testStatusCode505IsHttpVersionNotSupported() {
        XCTAssertEqual(HTTPNetworkingServerError.fromStatusCode(505), .httpVersionNotSupported)
    }
    
    func testStatusCode506IsVariantAlsoNegotiates() {
        XCTAssertEqual(HTTPNetworkingServerError.fromStatusCode(506), .variantAlsoNegotiates)
    }
    
    func testStatusCode507IsInsufficientStorage() {
        XCTAssertEqual(HTTPNetworkingServerError.fromStatusCode(507), .insufficientStorage)
    }
    
    func testStatusCode508IsLoopDetected() {
        XCTAssertEqual(HTTPNetworkingServerError.fromStatusCode(508), .loopDetected)
    }
    
    func testStatusCode510IsNotExtended() {
        XCTAssertEqual(HTTPNetworkingServerError.fromStatusCode(510), .notExtended)
    }
    
    func testStatusCode511IsNetworkAuthenticationRequired() {
        XCTAssertEqual(HTTPNetworkingServerError.fromStatusCode(511), .networkAuthenticationRequired)
    }
}
