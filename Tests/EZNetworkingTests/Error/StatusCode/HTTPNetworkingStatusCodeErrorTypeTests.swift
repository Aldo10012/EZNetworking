import XCTest
@testable import EZNetworking

final class HTTPNetworkingStatusCodeErrorTypeTests: XCTestCase {
    
    func testStatusCode200IsOk() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 200), .ok)
    }
    
    func testStatusCode300IsMultipleChoices() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 300), .redirectionMessageError(.multipleChoices))
    }
    
    func testStatusCode301IsMovedPermanently() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 301), .redirectionMessageError(.movedPermanently))
    }
    
    func testStatusCode302IsFound() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 302), .redirectionMessageError(.found))
    }
    
    func testStatusCode303IsSeeOther() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 303), .redirectionMessageError(.seeOther))
    }
    
    func testStatusCode304IsNotModified() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 304), .redirectionMessageError(.notModified))
    }
    
    func testStatusCode305IsUseProxy() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 305), .redirectionMessageError(.useProxy))
    }
    
    func testStatusCode307IsTemporaryRedirect() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 307), .redirectionMessageError(.temporaryRedirect))
    }
    
    func testStatusCode308IsPermanentRedirect() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 308), .redirectionMessageError(.permanentRedirect))
    }
    
    func testStatusCode400IsBadRequest() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 400), .clientSideError(.badRequest))
    }
    
    func testStatusCode401IsUnauthorized() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 401), .clientSideError(.unauthorized))
    }
    
    func testStatusCode402IsPaymentRequired() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 402), .clientSideError(.paymentRequired))
    }
    
    func testStatusCode403IsForbidden() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 403), .clientSideError(.forbidden))
    }
    
    func testStatusCode404IsNotFound() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 404), .clientSideError(.notFound))
    }
    
    func testStatusCode405IsMethodNotAllowed() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 405), .clientSideError(.methodNotAllowed))
    }
    
    func testStatusCode406IsNotAcceptable() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 406), .clientSideError(.notAcceptable))
    }
    
    func testStatusCode407IsProxyAuthenticationRequired() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 407), .clientSideError(.proxyAuthenticationRequired))
    }
    
    func testStatusCode408IsRequestTimeout() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 408), .clientSideError(.requestTimeout))
    }
    
    func testStatusCode409IsConflict() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 409), .clientSideError(.conflict))
    }
    
    func testStatusCode410IsGone() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 410), .clientSideError(.gone))
    }
    
    func testStatusCode411IsLengthRequired() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 411), .clientSideError(.lengthRequired))
    }
    
    func testStatusCode412IsPreconditionFailed() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 412), .clientSideError(.preconditionFailed))
    }
    
    func testStatusCode413IsPayloadTooLarge() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 413), .clientSideError(.payloadTooLarge))
    }
    
    func testStatusCode414IsURITooLong() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 414), .clientSideError(.uriTooLong))
    }
    
    func testStatusCode415IsUnsupportedMediaType() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 415), .clientSideError(.unsupportedMediaType))
    }
    
    func testStatusCode416IsRangeNotSatisfiable() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 416), .clientSideError(.rangeNotSatisfiable))
    }
    
    func testStatusCode417IsExpectationFailed() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 417), .clientSideError(.expectationFailed))
    }
    
    func testStatusCode418IsImATeapot() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 418), .clientSideError(.imATeapot))
    }
    
    func testStatusCode421IsMisdirectedRequest() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 421), .clientSideError(.misdirectedRequest))
    }
    
    func testStatusCode422IsUnprocessableEntity() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 422), .clientSideError(.unprocessableEntity))
    }
    
    func testStatusCode423IsLocked() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 423), .clientSideError(.locked))
    }
    
    func testStatusCode424IsFailedDependency() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 424), .clientSideError(.failedDependency))
    }
    
    func testStatusCode425IsTooEarly() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 425), .clientSideError(.tooEarly))
    }
    
    func testStatusCode426IsUpgradeRequired() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 426), .clientSideError(.upgradeRequired))
    }
    
    func testStatusCode428IsPreconditionRequired() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 428), .clientSideError(.preconditionRequired))
    }
    
    func testStatusCode429IsTooManyRequests() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 429), .clientSideError(.tooManyRequests))
    }
    
    func testStatusCode431IsRequestHeaderFieldsTooLarge() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 431), .clientSideError(.requestHeaderFieldsTooLarge))
    }
    
    func testStatusCode451IsUnavailableForLegalReasons() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 451), .clientSideError(.unavailableForLegalReasons))
    }
    
    func testStatusCode500IsInternalServerError() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 500), .serverSideError(.internalServerError))
    }
    
    func testStatusCode501IsNotImplemented() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 501), .serverSideError(.notImplemented))
    }
    
    func testStatusCode502IsBadGateway() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 502), .serverSideError(.badGateway))
    }
    
    func testStatusCode503IsServiceUnavailable() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 503), .serverSideError(.serviceUnavailable))
    }
    
    func testStatusCode504IsGatewayTimeout() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 504), .serverSideError(.gatewayTimeout))
    }
    
    func testStatusCode505IsHttpVersionNotSupported() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 505), .serverSideError(.httpVersionNotSupported))
    }
    
    func testStatusCode506IsVariantAlsoNegotiates() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 506), .serverSideError(.variantAlsoNegotiates))
    }
    
    func testStatusCode507IsInsufficientStorage() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 507), .serverSideError(.insufficientStorage))
    }
    
    func testStatusCode508IsLoopDetected() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 508), .serverSideError(.loopDetected))
    }
    
    func testStatusCode510IsNotExtended() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 510), .serverSideError(.notExtended))
    }
    
    func testStatusCode511IsNetworkAuthenticationRequired() {
        XCTAssertEqual(HTTPNetworkingStatusCodeErrorType.evaluate(from: 511), .serverSideError(.networkAuthenticationRequired))
    }
}
