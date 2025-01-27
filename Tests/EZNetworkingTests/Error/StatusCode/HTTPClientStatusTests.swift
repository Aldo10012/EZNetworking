import XCTest
@testable import EZNetworking

final class HTTPClientStatusTests: XCTestCase {
    func testStatusCode400IsBadRequest() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 400), .badRequest)
    }
    
    func testStatusCode401IsUnauthorized() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 401), .unauthorized)
    }
    
    func testStatusCode402IsPaymentRequired() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 402), .paymentRequired)
    }
    
    func testStatusCode403IsForbidden() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 403), .forbidden)
    }
    
    func testStatusCode404IsNotFound() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 404), .notFound)
    }
    
    func testStatusCode405IsMethodNotAllowed() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 405), .methodNotAllowed)
    }
    
    func testStatusCode406IsNotAcceptable() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 406), .notAcceptable)
    }
    
    func testStatusCode407IsProxyAuthenticationRequired() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 407), .proxyAuthenticationRequired)
    }
    
    func testStatusCode408IsRequestTimeout() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 408), .requestTimeout)
    }
    
    func testStatusCode409IsConflict() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 409), .conflict)
    }
    
    func testStatusCode410IsGone() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 410), .gone)
    }
    
    func testStatusCode411IsLengthRequired() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 411), .lengthRequired)
    }
    
    func testStatusCode412IsPreconditionFailed() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 412), .preconditionFailed)
    }
    
    func testStatusCode413IsPayloadTooLarge() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 413), .payloadTooLarge)
    }
    
    func testStatusCode414IsURITooLong() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 414), .uriTooLong)
    }
    
    func testStatusCode415IsUnsupportedMediaType() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 415), .unsupportedMediaType)
    }
    
    func testStatusCode416IsRangeNotSatisfiable() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 416), .rangeNotSatisfiable)
    }
    
    func testStatusCode417IsExpectationFailed() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 417), .expectationFailed)
    }
    
    func testStatusCode418IsImATeapot() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 418), .imATeapot)
    }
    
    func testStatusCode421IsMisdirectedRequest() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 421), .misdirectedRequest)
    }
    
    func testStatusCode422IsUnprocessableEntity() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 422), .unprocessableEntity)
    }
    
    func testStatusCode423IsLocked() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 423), .locked)
    }
    
    func testStatusCode424IsFailedDependency() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 424), .failedDependency)
    }
    
    func testStatusCode425IsTooEarly() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 425), .tooEarly)
    }
    
    func testStatusCode426IsUpgradeRequired() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 426), .upgradeRequired)
    }
    
    func testStatusCode428IsPreconditionRequired() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 428), .preconditionRequired)
    }
    
    func testStatusCode429IsTooManyRequests() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 429), .tooManyRequests)
    }
    
    func testStatusCode431IsRequestHeaderFieldsTooLarge() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 431), .requestHeaderFieldsTooLarge)
    }
    
    func testStatusCode451IsUnavailableForLegalReasons() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 451), .unavailableForLegalReasons)
    }
    
    func testStatusCode451IsUnknowns() {
        XCTAssertEqual(HTTPClientStatus(statusCode: 452), .unknown)
    }
    
    func testDifferentHTTPNetworkingClientErrorsAreNotEquatable() {
        XCTAssertNotEqual(HTTPClientStatus.badRequest, HTTPClientStatus.conflict)
    }
}
