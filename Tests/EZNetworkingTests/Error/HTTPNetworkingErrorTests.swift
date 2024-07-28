import XCTest
@testable import EZNetworking

final class HTTPNetworkingErrorTests: XCTestCase {
    
    func testStatusCode200IsOk() {
        XCTAssertEqual(buildResponse(statusCode: 200).networkingError, nil)
    }
    
    func testStatusCode300IsMultipleChoices() {
        XCTAssertEqual(buildResponse(statusCode: 300).networkingError, HTTPNetworkingError.multipleChoices)
    }
    
    func testStatusCode301IsMovedPermanently() {
        XCTAssertEqual(buildResponse(statusCode: 301).networkingError, HTTPNetworkingError.movedPermanently)
    }
    
    func testStatusCode302IsFound() {
        XCTAssertEqual(buildResponse(statusCode: 302).networkingError, HTTPNetworkingError.found)
    }
    
    func testStatusCode303IsSeeOther() {
        XCTAssertEqual(buildResponse(statusCode: 303).networkingError, HTTPNetworkingError.seeOther)
    }
    
    func testStatusCode304IsNotModified() {
        XCTAssertEqual(buildResponse(statusCode: 304).networkingError, HTTPNetworkingError.notModified)
    }
    
    func testStatusCode305IsUseProxy() {
        XCTAssertEqual(buildResponse(statusCode: 305).networkingError, HTTPNetworkingError.useProxy)
    }
    
    func testStatusCode307IsTemporaryRedirect() {
        XCTAssertEqual(buildResponse(statusCode: 307).networkingError, HTTPNetworkingError.temporaryRedirect)
    }
    
    func testStatusCode308IsPermanentRedirect() {
        XCTAssertEqual(buildResponse(statusCode: 308).networkingError, HTTPNetworkingError.permanentRedirect)
    }
    
    func testStatusCode400IsBadRequest() {
        XCTAssertEqual(buildResponse(statusCode: 400).networkingError, HTTPNetworkingError.badRequest)
    }
    
    func testStatusCode401IsUnauthorized() {
        XCTAssertEqual(buildResponse(statusCode: 401).networkingError, HTTPNetworkingError.unauthorized)
    }
    
    func testStatusCode402IsPaymentRequired() {
        XCTAssertEqual(buildResponse(statusCode: 402).networkingError, HTTPNetworkingError.paymentRequired)
    }
    
    func testStatusCode403IsForbidden() {
        XCTAssertEqual(buildResponse(statusCode: 403).networkingError, HTTPNetworkingError.forbidden)
    }
    
    func testStatusCode404IsNotFound() {
        XCTAssertEqual(buildResponse(statusCode: 404).networkingError, HTTPNetworkingError.notFound)
    }
    
    func testStatusCode405IsMethodNotAllowed() {
        XCTAssertEqual(buildResponse(statusCode: 405).networkingError, HTTPNetworkingError.methodNotAllowed)
    }
    
    func testStatusCode406IsNotAcceptable() {
        XCTAssertEqual(buildResponse(statusCode: 406).networkingError, HTTPNetworkingError.notAcceptable)
    }
    
    func testStatusCode407IsProxyAuthenticationRequired() {
        XCTAssertEqual(buildResponse(statusCode: 407).networkingError, HTTPNetworkingError.proxyAuthenticationRequired)
    }
    
    func testStatusCode408IsRequestTimeout() {
        XCTAssertEqual(buildResponse(statusCode: 408).networkingError, HTTPNetworkingError.requestTimeout)
    }
    
    func testStatusCode409IsConflict() {
        XCTAssertEqual(buildResponse(statusCode: 409).networkingError, HTTPNetworkingError.conflict)
    }
    
    func testStatusCode410IsGone() {
        XCTAssertEqual(buildResponse(statusCode: 410).networkingError, HTTPNetworkingError.gone)
    }
    
    func testStatusCode411IsLengthRequired() {
        XCTAssertEqual(buildResponse(statusCode: 411).networkingError, HTTPNetworkingError.lengthRequired)
    }
    
    func testStatusCode412IsPreconditionFailed() {
        XCTAssertEqual(buildResponse(statusCode: 412).networkingError, HTTPNetworkingError.preconditionFailed)
    }
    
    func testStatusCode413IsPayloadTooLarge() {
        XCTAssertEqual(buildResponse(statusCode: 413).networkingError, HTTPNetworkingError.payloadTooLarge)
    }
    
    func testStatusCode414IsURITooLong() {
        XCTAssertEqual(buildResponse(statusCode: 414).networkingError, HTTPNetworkingError.uriTooLong)
    }
    
    func testStatusCode415IsUnsupportedMediaType() {
        XCTAssertEqual(buildResponse(statusCode: 415).networkingError, HTTPNetworkingError.unsupportedMediaType)
    }
    
    func testStatusCode416IsRangeNotSatisfiable() {
        XCTAssertEqual(buildResponse(statusCode: 416).networkingError, HTTPNetworkingError.rangeNotSatisfiable)
    }
    
    func testStatusCode417IsExpectationFailed() {
        XCTAssertEqual(buildResponse(statusCode: 417).networkingError, HTTPNetworkingError.expectationFailed)
    }
    
    func testStatusCode418IsImATeapot() {
        XCTAssertEqual(buildResponse(statusCode: 418).networkingError, HTTPNetworkingError.imATeapot)
    }
    
    func testStatusCode421IsMisdirectedRequest() {
        XCTAssertEqual(buildResponse(statusCode: 421).networkingError, HTTPNetworkingError.misdirectedRequest)
    }
    
    func testStatusCode422IsUnprocessableEntity() {
        XCTAssertEqual(buildResponse(statusCode: 422).networkingError, HTTPNetworkingError.unprocessableEntity)
    }
    
    func testStatusCode423IsLocked() {
        XCTAssertEqual(buildResponse(statusCode: 423).networkingError, HTTPNetworkingError.locked)
    }
    
    func testStatusCode424IsFailedDependency() {
        XCTAssertEqual(buildResponse(statusCode: 424).networkingError, HTTPNetworkingError.failedDependency)
    }
    
    func testStatusCode425IsTooEarly() {
        XCTAssertEqual(buildResponse(statusCode: 425).networkingError, HTTPNetworkingError.tooEarly)
    }
    
    func testStatusCode426IsUpgradeRequired() {
        XCTAssertEqual(buildResponse(statusCode: 426).networkingError, HTTPNetworkingError.upgradeRequired)
    }
    
    func testStatusCode428IsPreconditionRequired() {
        XCTAssertEqual(buildResponse(statusCode: 428).networkingError, HTTPNetworkingError.preconditionRequired)
    }
    
    func testStatusCode429IsTooManyRequests() {
        XCTAssertEqual(buildResponse(statusCode: 429).networkingError, HTTPNetworkingError.tooManyRequests)
    }
    
    func testStatusCode431IsRequestHeaderFieldsTooLarge() {
        XCTAssertEqual(buildResponse(statusCode: 431).networkingError, HTTPNetworkingError.requestHeaderFieldsTooLarge)
    }
    
    func testStatusCode451IsUnavailableForLegalReasons() {
        XCTAssertEqual(buildResponse(statusCode: 451).networkingError, HTTPNetworkingError.unavailableForLegalReasons)
    }
    
    func testStatusCode500IsInternalServerError() {
        XCTAssertEqual(buildResponse(statusCode: 500).networkingError, HTTPNetworkingError.internalServerError)
    }
    
    func testStatusCode501IsNotImplemented() {
        XCTAssertEqual(buildResponse(statusCode: 501).networkingError, HTTPNetworkingError.notImplemented)
    }
    
    func testStatusCode502IsBadGateway() {
        XCTAssertEqual(buildResponse(statusCode: 502).networkingError, HTTPNetworkingError.badGateway)
    }
    
    func testStatusCode503IsServiceUnavailable() {
        XCTAssertEqual(buildResponse(statusCode: 503).networkingError, HTTPNetworkingError.serviceUnavailable)
    }
    
    func testStatusCode504IsGatewayTimeout() {
        XCTAssertEqual(buildResponse(statusCode: 504).networkingError, HTTPNetworkingError.gatewayTimeout)
    }
    
    func testStatusCode505IsHttpVersionNotSupported() {
        XCTAssertEqual(buildResponse(statusCode: 505).networkingError, HTTPNetworkingError.httpVersionNotSupported)
    }
    
    func testStatusCode506IsVariantAlsoNegotiates() {
        XCTAssertEqual(buildResponse(statusCode: 506).networkingError, HTTPNetworkingError.variantAlsoNegotiates)
    }
    
    func testStatusCode507IsInsufficientStorage() {
        XCTAssertEqual(buildResponse(statusCode: 507).networkingError, HTTPNetworkingError.insufficientStorage)
    }
    
    func testStatusCode508IsLoopDetected() {
        XCTAssertEqual(buildResponse(statusCode: 508).networkingError, HTTPNetworkingError.loopDetected)
    }
    
    func testStatusCode510IsNotExtended() {
        XCTAssertEqual(buildResponse(statusCode: 510).networkingError, HTTPNetworkingError.notExtended)
    }
    
    func testStatusCode511IsNetworkAuthenticationRequired() {
        XCTAssertEqual(buildResponse(statusCode: 511).networkingError, HTTPNetworkingError.networkAuthenticationRequired)
    }
    
    
    private func buildResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }
    
}
