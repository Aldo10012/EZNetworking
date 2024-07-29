import XCTest
@testable import EZNetworking

final class HTTPNetworkingErrorTests: XCTestCase {
    
    func testStatusCode200IsOk() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(200), nil)
    }
    
    func testStatusCode300IsMultipleChoices() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(300), HTTPNetworkingError.multipleChoices)
    }
    
    func testStatusCode301IsMovedPermanently() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(301), HTTPNetworkingError.movedPermanently)
    }
    
    func testStatusCode302IsFound() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(302), HTTPNetworkingError.found)
    }
    
    func testStatusCode303IsSeeOther() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(303), HTTPNetworkingError.seeOther)
    }
    
    func testStatusCode304IsNotModified() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(304), HTTPNetworkingError.notModified)
    }
    
    func testStatusCode305IsUseProxy() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(305), HTTPNetworkingError.useProxy)
    }
    
    func testStatusCode307IsTemporaryRedirect() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(307), HTTPNetworkingError.temporaryRedirect)
    }
    
    func testStatusCode308IsPermanentRedirect() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(308), HTTPNetworkingError.permanentRedirect)
    }
    
    func testStatusCode400IsBadRequest() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(400), HTTPNetworkingError.badRequest)
    }
    
    func testStatusCode401IsUnauthorized() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(401), HTTPNetworkingError.unauthorized)
    }
    
    func testStatusCode402IsPaymentRequired() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(402), HTTPNetworkingError.paymentRequired)
    }
    
    func testStatusCode403IsForbidden() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(403), HTTPNetworkingError.forbidden)
    }
    
    func testStatusCode404IsNotFound() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(404), HTTPNetworkingError.notFound)
    }
    
    func testStatusCode405IsMethodNotAllowed() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(405), HTTPNetworkingError.methodNotAllowed)
    }
    
    func testStatusCode406IsNotAcceptable() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(406), HTTPNetworkingError.notAcceptable)
    }
    
    func testStatusCode407IsProxyAuthenticationRequired() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(407), HTTPNetworkingError.proxyAuthenticationRequired)
    }
    
    func testStatusCode408IsRequestTimeout() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(408), HTTPNetworkingError.requestTimeout)
    }
    
    func testStatusCode409IsConflict() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(409), HTTPNetworkingError.conflict)
    }
    
    func testStatusCode410IsGone() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(410), HTTPNetworkingError.gone)
    }
    
    func testStatusCode411IsLengthRequired() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(411), HTTPNetworkingError.lengthRequired)
    }
    
    func testStatusCode412IsPreconditionFailed() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(412), HTTPNetworkingError.preconditionFailed)
    }
    
    func testStatusCode413IsPayloadTooLarge() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(413), HTTPNetworkingError.payloadTooLarge)
    }
    
    func testStatusCode414IsURITooLong() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(414), HTTPNetworkingError.uriTooLong)
    }
    
    func testStatusCode415IsUnsupportedMediaType() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(415), HTTPNetworkingError.unsupportedMediaType)
    }
    
    func testStatusCode416IsRangeNotSatisfiable() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(416), HTTPNetworkingError.rangeNotSatisfiable)
    }
    
    func testStatusCode417IsExpectationFailed() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(417), HTTPNetworkingError.expectationFailed)
    }
    
    func testStatusCode418IsImATeapot() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(418), HTTPNetworkingError.imATeapot)
    }
    
    func testStatusCode421IsMisdirectedRequest() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(421), HTTPNetworkingError.misdirectedRequest)
    }
    
    func testStatusCode422IsUnprocessableEntity() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(422), HTTPNetworkingError.unprocessableEntity)
    }
    
    func testStatusCode423IsLocked() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(423), HTTPNetworkingError.locked)
    }
    
    func testStatusCode424IsFailedDependency() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(424), HTTPNetworkingError.failedDependency)
    }
    
    func testStatusCode425IsTooEarly() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(425), HTTPNetworkingError.tooEarly)
    }
    
    func testStatusCode426IsUpgradeRequired() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(426), HTTPNetworkingError.upgradeRequired)
    }
    
    func testStatusCode428IsPreconditionRequired() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(428), HTTPNetworkingError.preconditionRequired)
    }
    
    func testStatusCode429IsTooManyRequests() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(429), HTTPNetworkingError.tooManyRequests)
    }
    
    func testStatusCode431IsRequestHeaderFieldsTooLarge() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(431), HTTPNetworkingError.requestHeaderFieldsTooLarge)
    }
    
    func testStatusCode451IsUnavailableForLegalReasons() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(451), HTTPNetworkingError.unavailableForLegalReasons)
    }
    
    func testStatusCode500IsInternalServerError() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(500), HTTPNetworkingError.internalServerError)
    }
    
    func testStatusCode501IsNotImplemented() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(501), HTTPNetworkingError.notImplemented)
    }
    
    func testStatusCode502IsBadGateway() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(502), HTTPNetworkingError.badGateway)
    }
    
    func testStatusCode503IsServiceUnavailable() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(503), HTTPNetworkingError.serviceUnavailable)
    }
    
    func testStatusCode504IsGatewayTimeout() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(504), HTTPNetworkingError.gatewayTimeout)
    }
    
    func testStatusCode505IsHttpVersionNotSupported() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(505), HTTPNetworkingError.httpVersionNotSupported)
    }
    
    func testStatusCode506IsVariantAlsoNegotiates() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(506), HTTPNetworkingError.variantAlsoNegotiates)
    }
    
    func testStatusCode507IsInsufficientStorage() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(507), HTTPNetworkingError.insufficientStorage)
    }
    
    func testStatusCode508IsLoopDetected() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(508), HTTPNetworkingError.loopDetected)
    }
    
    func testStatusCode510IsNotExtended() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(510), HTTPNetworkingError.notExtended)
    }
    
    func testStatusCode511IsNetworkAuthenticationRequired() {
        XCTAssertEqual(HTTPNetworkingError.fromStatusCode(511), HTTPNetworkingError.networkAuthenticationRequired)
    }
}
