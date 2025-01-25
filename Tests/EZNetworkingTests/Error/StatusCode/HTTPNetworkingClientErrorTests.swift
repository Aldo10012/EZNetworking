import XCTest
@testable import EZNetworking

final class HTTPNetworkingClientErrorTests: XCTestCase {
    func testStatusCode400IsBadRequest() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(400), .badRequest)
    }
    
    func testStatusCode401IsUnauthorized() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(401), .unauthorized)
    }
    
    func testStatusCode402IsPaymentRequired() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(402), .paymentRequired)
    }
    
    func testStatusCode403IsForbidden() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(403), .forbidden)
    }
    
    func testStatusCode404IsNotFound() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(404), .notFound)
    }
    
    func testStatusCode405IsMethodNotAllowed() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(405), .methodNotAllowed)
    }
    
    func testStatusCode406IsNotAcceptable() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(406), .notAcceptable)
    }
    
    func testStatusCode407IsProxyAuthenticationRequired() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(407), .proxyAuthenticationRequired)
    }
    
    func testStatusCode408IsRequestTimeout() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(408), .requestTimeout)
    }
    
    func testStatusCode409IsConflict() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(409), .conflict)
    }
    
    func testStatusCode410IsGone() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(410), .gone)
    }
    
    func testStatusCode411IsLengthRequired() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(411), .lengthRequired)
    }
    
    func testStatusCode412IsPreconditionFailed() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(412), .preconditionFailed)
    }
    
    func testStatusCode413IsPayloadTooLarge() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(413), .payloadTooLarge)
    }
    
    func testStatusCode414IsURITooLong() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(414), .uriTooLong)
    }
    
    func testStatusCode415IsUnsupportedMediaType() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(415), .unsupportedMediaType)
    }
    
    func testStatusCode416IsRangeNotSatisfiable() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(416), .rangeNotSatisfiable)
    }
    
    func testStatusCode417IsExpectationFailed() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(417), .expectationFailed)
    }
    
    func testStatusCode418IsImATeapot() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(418), .imATeapot)
    }
    
    func testStatusCode421IsMisdirectedRequest() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(421), .misdirectedRequest)
    }
    
    func testStatusCode422IsUnprocessableEntity() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(422), .unprocessableEntity)
    }
    
    func testStatusCode423IsLocked() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(423), .locked)
    }
    
    func testStatusCode424IsFailedDependency() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(424), .failedDependency)
    }
    
    func testStatusCode425IsTooEarly() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(425), .tooEarly)
    }
    
    func testStatusCode426IsUpgradeRequired() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(426), .upgradeRequired)
    }
    
    func testStatusCode428IsPreconditionRequired() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(428), .preconditionRequired)
    }
    
    func testStatusCode429IsTooManyRequests() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(429), .tooManyRequests)
    }
    
    func testStatusCode431IsRequestHeaderFieldsTooLarge() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(431), .requestHeaderFieldsTooLarge)
    }
    
    func testStatusCode451IsUnavailableForLegalReasons() {
        XCTAssertEqual(HTTPNetworkingClientError.fromStatusCode(451), .unavailableForLegalReasons)
    }
}
