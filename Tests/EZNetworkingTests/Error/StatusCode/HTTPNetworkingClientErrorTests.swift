import XCTest
@testable import EZNetworking

final class HTTPNetworkingClientErrorTests: XCTestCase {
    func testStatusCode400IsBadRequest() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 400), .badRequest)
    }
    
    func testStatusCode401IsUnauthorized() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 401), .unauthorized)
    }
    
    func testStatusCode402IsPaymentRequired() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 402), .paymentRequired)
    }
    
    func testStatusCode403IsForbidden() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 403), .forbidden)
    }
    
    func testStatusCode404IsNotFound() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 404), .notFound)
    }
    
    func testStatusCode405IsMethodNotAllowed() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 405), .methodNotAllowed)
    }
    
    func testStatusCode406IsNotAcceptable() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 406), .notAcceptable)
    }
    
    func testStatusCode407IsProxyAuthenticationRequired() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 407), .proxyAuthenticationRequired)
    }
    
    func testStatusCode408IsRequestTimeout() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 408), .requestTimeout)
    }
    
    func testStatusCode409IsConflict() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 409), .conflict)
    }
    
    func testStatusCode410IsGone() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 410), .gone)
    }
    
    func testStatusCode411IsLengthRequired() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 411), .lengthRequired)
    }
    
    func testStatusCode412IsPreconditionFailed() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 412), .preconditionFailed)
    }
    
    func testStatusCode413IsPayloadTooLarge() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 413), .payloadTooLarge)
    }
    
    func testStatusCode414IsURITooLong() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 414), .uriTooLong)
    }
    
    func testStatusCode415IsUnsupportedMediaType() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 415), .unsupportedMediaType)
    }
    
    func testStatusCode416IsRangeNotSatisfiable() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 416), .rangeNotSatisfiable)
    }
    
    func testStatusCode417IsExpectationFailed() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 417), .expectationFailed)
    }
    
    func testStatusCode418IsImATeapot() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 418), .imATeapot)
    }
    
    func testStatusCode421IsMisdirectedRequest() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 421), .misdirectedRequest)
    }
    
    func testStatusCode422IsUnprocessableEntity() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 422), .unprocessableEntity)
    }
    
    func testStatusCode423IsLocked() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 423), .locked)
    }
    
    func testStatusCode424IsFailedDependency() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 424), .failedDependency)
    }
    
    func testStatusCode425IsTooEarly() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 425), .tooEarly)
    }
    
    func testStatusCode426IsUpgradeRequired() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 426), .upgradeRequired)
    }
    
    func testStatusCode428IsPreconditionRequired() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 428), .preconditionRequired)
    }
    
    func testStatusCode429IsTooManyRequests() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 429), .tooManyRequests)
    }
    
    func testStatusCode431IsRequestHeaderFieldsTooLarge() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 431), .requestHeaderFieldsTooLarge)
    }
    
    func testStatusCode451IsUnavailableForLegalReasons() {
        XCTAssertEqual(HTTPNetworkingClientError(statusCode: 451), .unavailableForLegalReasons)
    }
}
