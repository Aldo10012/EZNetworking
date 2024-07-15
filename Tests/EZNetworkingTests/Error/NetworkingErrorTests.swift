//
//  NetworkingErrorTests.swift
//
//
//  Created by Alberto Dominguez on 7/14/24.
//

import XCTest
@testable import EZNetworking

final class NetworkingErrorTests: XCTestCase {
    
    func testStatusCode200IsOk() {
        XCTAssertEqual(buildResponse(statusCode: 200).networkingError, NetworkingError.ok)
    }
    
    func testStatusCode300IsMultipleChoices() {
        XCTAssertEqual(buildResponse(statusCode: 300).networkingError, NetworkingError.multipleChoices)
    }
    
    func testStatusCode301IsMovedPermanently() {
        XCTAssertEqual(buildResponse(statusCode: 301).networkingError, NetworkingError.movedPermanently)
    }
    
    func testStatusCode302IsFound() {
        XCTAssertEqual(buildResponse(statusCode: 302).networkingError, NetworkingError.found)
    }
    
    func testStatusCode303IsSeeOther() {
        XCTAssertEqual(buildResponse(statusCode: 303).networkingError, NetworkingError.seeOther)
    }
    
    func testStatusCode304IsNotModified() {
        XCTAssertEqual(buildResponse(statusCode: 304).networkingError, NetworkingError.notModified)
    }
    
    func testStatusCode305IsUseProxy() {
        XCTAssertEqual(buildResponse(statusCode: 305).networkingError, NetworkingError.useProxy)
    }
    
    func testStatusCode307IsTemporaryRedirect() {
        XCTAssertEqual(buildResponse(statusCode: 307).networkingError, NetworkingError.temporaryRedirect)
    }
    
    func testStatusCode308IsPermanentRedirect() {
        XCTAssertEqual(buildResponse(statusCode: 308).networkingError, NetworkingError.permanentRedirect)
    }
    
    func testStatusCode400IsBadRequest() {
        XCTAssertEqual(buildResponse(statusCode: 400).networkingError, NetworkingError.badRequest)
    }
    
    func testStatusCode401IsUnauthorized() {
        XCTAssertEqual(buildResponse(statusCode: 401).networkingError, NetworkingError.unauthorized)
    }
    
    func testStatusCode402IsPaymentRequired() {
        XCTAssertEqual(buildResponse(statusCode: 402).networkingError, NetworkingError.paymentRequired)
    }
    
    func testStatusCode403IsForbidden() {
        XCTAssertEqual(buildResponse(statusCode: 403).networkingError, NetworkingError.forbidden)
    }
    
    func testStatusCode404IsNotFound() {
        XCTAssertEqual(buildResponse(statusCode: 404).networkingError, NetworkingError.notFound)
    }
    
    func testStatusCode405IsMethodNotAllowed() {
        XCTAssertEqual(buildResponse(statusCode: 405).networkingError, NetworkingError.methodNotAllowed)
    }
    
    func testStatusCode406IsNotAcceptable() {
        XCTAssertEqual(buildResponse(statusCode: 406).networkingError, NetworkingError.notAcceptable)
    }
    
    func testStatusCode407IsProxyAuthenticationRequired() {
        XCTAssertEqual(buildResponse(statusCode: 407).networkingError, NetworkingError.proxyAuthenticationRequired)
    }
    
    func testStatusCode408IsRequestTimeout() {
        XCTAssertEqual(buildResponse(statusCode: 408).networkingError, NetworkingError.requestTimeout)
    }
    
    func testStatusCode409IsConflict() {
        XCTAssertEqual(buildResponse(statusCode: 409).networkingError, NetworkingError.conflict)
    }
    
    func testStatusCode410IsGone() {
        XCTAssertEqual(buildResponse(statusCode: 410).networkingError, NetworkingError.gone)
    }
    
    func testStatusCode411IsLengthRequired() {
        XCTAssertEqual(buildResponse(statusCode: 411).networkingError, NetworkingError.lengthRequired)
    }
    
    func testStatusCode412IsPreconditionFailed() {
        XCTAssertEqual(buildResponse(statusCode: 412).networkingError, NetworkingError.preconditionFailed)
    }
    
    func testStatusCode413IsPayloadTooLarge() {
        XCTAssertEqual(buildResponse(statusCode: 413).networkingError, NetworkingError.payloadTooLarge)
    }
    
    func testStatusCode414IsURITooLong() {
        XCTAssertEqual(buildResponse(statusCode: 414).networkingError, NetworkingError.uriTooLong)
    }
    
    func testStatusCode415IsUnsupportedMediaType() {
        XCTAssertEqual(buildResponse(statusCode: 415).networkingError, NetworkingError.unsupportedMediaType)
    }
    
    func testStatusCode416IsRangeNotSatisfiable() {
        XCTAssertEqual(buildResponse(statusCode: 416).networkingError, NetworkingError.rangeNotSatisfiable)
    }
    
    func testStatusCode417IsExpectationFailed() {
        XCTAssertEqual(buildResponse(statusCode: 417).networkingError, NetworkingError.expectationFailed)
    }
    
    func testStatusCode418IsImATeapot() {
        XCTAssertEqual(buildResponse(statusCode: 418).networkingError, NetworkingError.imATeapot)
    }
    
    func testStatusCode421IsMisdirectedRequest() {
        XCTAssertEqual(buildResponse(statusCode: 421).networkingError, NetworkingError.misdirectedRequest)
    }
    
    func testStatusCode422IsUnprocessableEntity() {
        XCTAssertEqual(buildResponse(statusCode: 422).networkingError, NetworkingError.unprocessableEntity)
    }
    
    func testStatusCode423IsLocked() {
        XCTAssertEqual(buildResponse(statusCode: 423).networkingError, NetworkingError.locked)
    }
    
    func testStatusCode424IsFailedDependency() {
        XCTAssertEqual(buildResponse(statusCode: 424).networkingError, NetworkingError.failedDependency)
    }
    
    func testStatusCode425IsTooEarly() {
        XCTAssertEqual(buildResponse(statusCode: 425).networkingError, NetworkingError.tooEarly)
    }
    
    func testStatusCode426IsUpgradeRequired() {
        XCTAssertEqual(buildResponse(statusCode: 426).networkingError, NetworkingError.upgradeRequired)
    }
    
    func testStatusCode428IsPreconditionRequired() {
        XCTAssertEqual(buildResponse(statusCode: 428).networkingError, NetworkingError.preconditionRequired)
    }
    
    func testStatusCode429IsTooManyRequests() {
        XCTAssertEqual(buildResponse(statusCode: 429).networkingError, NetworkingError.tooManyRequests)
    }
    
    func testStatusCode431IsRequestHeaderFieldsTooLarge() {
        XCTAssertEqual(buildResponse(statusCode: 431).networkingError, NetworkingError.requestHeaderFieldsTooLarge)
    }
    
    func testStatusCode451IsUnavailableForLegalReasons() {
        XCTAssertEqual(buildResponse(statusCode: 451).networkingError, NetworkingError.unavailableForLegalReasons)
    }
    
    func testStatusCode500IsInternalServerError() {
        XCTAssertEqual(buildResponse(statusCode: 500).networkingError, NetworkingError.internalServerError)
    }
    
    func testStatusCode501IsNotImplemented() {
        XCTAssertEqual(buildResponse(statusCode: 501).networkingError, NetworkingError.notImplemented)
    }
    
    func testStatusCode502IsBadGateway() {
        XCTAssertEqual(buildResponse(statusCode: 502).networkingError, NetworkingError.badGateway)
    }
    
    func testStatusCode503IsServiceUnavailable() {
        XCTAssertEqual(buildResponse(statusCode: 503).networkingError, NetworkingError.serviceUnavailable)
    }
    
    func testStatusCode504IsGatewayTimeout() {
        XCTAssertEqual(buildResponse(statusCode: 504).networkingError, NetworkingError.gatewayTimeout)
    }
    
    func testStatusCode505IsHttpVersionNotSupported() {
        XCTAssertEqual(buildResponse(statusCode: 505).networkingError, NetworkingError.httpVersionNotSupported)
    }
    
    func testStatusCode506IsVariantAlsoNegotiates() {
        XCTAssertEqual(buildResponse(statusCode: 506).networkingError, NetworkingError.variantAlsoNegotiates)
    }
    
    func testStatusCode507IsInsufficientStorage() {
        XCTAssertEqual(buildResponse(statusCode: 507).networkingError, NetworkingError.insufficientStorage)
    }
    
    func testStatusCode508IsLoopDetected() {
        XCTAssertEqual(buildResponse(statusCode: 508).networkingError, NetworkingError.loopDetected)
    }
    
    func testStatusCode510IsNotExtended() {
        XCTAssertEqual(buildResponse(statusCode: 510).networkingError, NetworkingError.notExtended)
    }
    
    func testStatusCode511IsNetworkAuthenticationRequired() {
        XCTAssertEqual(buildResponse(statusCode: 511).networkingError, NetworkingError.networkAuthenticationRequired)
    }
    
    
    private func buildResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }
    
}
