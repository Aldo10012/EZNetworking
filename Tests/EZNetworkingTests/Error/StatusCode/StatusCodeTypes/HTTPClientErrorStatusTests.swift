import XCTest
@testable import EZNetworking

final class HTTPClientErrorStatusTests: XCTestCase {
    func testStatusCode400IsBadRequest() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 400), .badRequest)
    }
    
    func testStatusCode401IsUnauthorized() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 401), .unauthorized)
    }
    
    func testStatusCode402IsPaymentRequired() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 402), .paymentRequired)
    }
    
    func testStatusCode403IsForbidden() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 403), .forbidden)
    }
    
    func testStatusCode404IsNotFound() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 404), .notFound)
    }
    
    func testStatusCode405IsMethodNotAllowed() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 405), .methodNotAllowed)
    }
    
    func testStatusCode406IsNotAcceptable() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 406), .notAcceptable)
    }
    
    func testStatusCode407IsProxyAuthenticationRequired() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 407), .proxyAuthenticationRequired)
    }
    
    func testStatusCode408IsRequestTimeout() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 408), .requestTimeout)
    }
    
    func testStatusCode409IsConflict() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 409), .conflict)
    }
    
    func testStatusCode410IsGone() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 410), .gone)
    }
    
    func testStatusCode411IsLengthRequired() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 411), .lengthRequired)
    }
    
    func testStatusCode412IsPreconditionFailed() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 412), .preconditionFailed)
    }
    
    func testStatusCode413IsPayloadTooLarge() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 413), .payloadTooLarge)
    }
    
    func testStatusCode414IsURITooLong() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 414), .uriTooLong)
    }
    
    func testStatusCode415IsUnsupportedMediaType() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 415), .unsupportedMediaType)
    }
    
    func testStatusCode416IsRangeNotSatisfiable() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 416), .rangeNotSatisfiable)
    }
    
    func testStatusCode417IsExpectationFailed() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 417), .expectationFailed)
    }
    
    func testStatusCode418IsImATeapot() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 418), .imATeapot)
    }
    
    func testStatusCode421IsMisdirectedRequest() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 421), .misdirectedRequest)
    }
    
    func testStatusCode422IsUnprocessableEntity() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 422), .unprocessableEntity)
    }
    
    func testStatusCode423IsLocked() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 423), .locked)
    }
    
    func testStatusCode424IsFailedDependency() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 424), .failedDependency)
    }
    
    func testStatusCode425IsTooEarly() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 425), .tooEarly)
    }
    
    func testStatusCode426IsUpgradeRequired() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 426), .upgradeRequired)
    }
    
    func testStatusCode428IsPreconditionRequired() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 428), .preconditionRequired)
    }
    
    func testStatusCode429IsTooManyRequests() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 429), .tooManyRequests)
    }
    
    func testStatusCode431IsRequestHeaderFieldsTooLarge() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 431), .requestHeaderFieldsTooLarge)
    }
    
    func testStatusCode451IsUnavailableForLegalReasons() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 451), .unavailableForLegalReasons)
    }
    
    func testStatusCode451IsUnknowns() {
        XCTAssertEqual(HTTPClientErrorStatus(statusCode: 452), .unknown)
    }
    
    func testDifferentHTTPNetworkingClientErrorsAreNotEquatable() {
        XCTAssertNotEqual(HTTPClientErrorStatus.badRequest, HTTPClientErrorStatus.conflict)
    }
}
