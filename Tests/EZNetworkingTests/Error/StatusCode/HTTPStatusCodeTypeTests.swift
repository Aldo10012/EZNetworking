import XCTest
@testable import EZNetworking

final class HTTPStatusCodeTypeTests: XCTestCase {
    
    func testStatusCode100Is() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 100), .information(.continueStatus))
    }
    
    func testStatusCode101Is() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 101), .information(.switchingProtocols))
    }
    
    func testStatusCode102Is() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 102), .information(.processing))
    }
    
    func testStatusCode200IsOk() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 200), .success(.ok))
    }
    
    func testStatusCode201IsCreated() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 201), .success(.created))
    }
    
    func testStatusCode202IsAccepted() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 202), .success(.accepted))
    }
    
    func testStatusCode203IsNonAuthoritativeInformation() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 203), .success(.nonAuthoritativeInformation))
    }
    
    func testStatusCode204IsNoContent() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 204), .success(.noContent))
    }
    
    func testStatusCode205IsResetContent() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 205), .success(.resetContent))
    }
    
    func testStatusCode206IsPartialContent() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 206), .success(.partialContent))
    }
    
    func testStatusCode207IsMultiStatus() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 207), .success(.multiStatus))
    }
    
    func testStatusCode208IsAlreadyReported() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 208), .success(.alreadyReported))
    }
    
    func testStatusCode226IsiMUsed() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 226), .success(.iMUsed))
    }
    
    func testStatusCode300IsMultipleChoices() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 300), .redirectionMessage(.multipleChoices))
    }
    
    func testStatusCode301IsMovedPermanently() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 301), .redirectionMessage(.movedPermanently))
    }
    
    func testStatusCode302IsFound() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 302), .redirectionMessage(.found))
    }
    
    func testStatusCode303IsSeeOther() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 303), .redirectionMessage(.seeOther))
    }
    
    func testStatusCode304IsNotModified() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 304), .redirectionMessage(.notModified))
    }
    
    func testStatusCode305IsUseProxy() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 305), .redirectionMessage(.useProxy))
    }
    
    func testStatusCode307IsTemporaryRedirect() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 307), .redirectionMessage(.temporaryRedirect))
    }
    
    func testStatusCode308IsPermanentRedirect() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 308), .redirectionMessage(.permanentRedirect))
    }
    
    func testStatusCode400IsBadRequest() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 400), .clientSideError(.badRequest))
    }
    
    func testStatusCode401IsUnauthorized() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 401), .clientSideError(.unauthorized))
    }
    
    func testStatusCode402IsPaymentRequired() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 402), .clientSideError(.paymentRequired))
    }
    
    func testStatusCode403IsForbidden() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 403), .clientSideError(.forbidden))
    }
    
    func testStatusCode404IsNotFound() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 404), .clientSideError(.notFound))
    }
    
    func testStatusCode405IsMethodNotAllowed() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 405), .clientSideError(.methodNotAllowed))
    }
    
    func testStatusCode406IsNotAcceptable() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 406), .clientSideError(.notAcceptable))
    }
    
    func testStatusCode407IsProxyAuthenticationRequired() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 407), .clientSideError(.proxyAuthenticationRequired))
    }
    
    func testStatusCode408IsRequestTimeout() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 408), .clientSideError(.requestTimeout))
    }
    
    func testStatusCode409IsConflict() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 409), .clientSideError(.conflict))
    }
    
    func testStatusCode410IsGone() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 410), .clientSideError(.gone))
    }
    
    func testStatusCode411IsLengthRequired() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 411), .clientSideError(.lengthRequired))
    }
    
    func testStatusCode412IsPreconditionFailed() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 412), .clientSideError(.preconditionFailed))
    }
    
    func testStatusCode413IsPayloadTooLarge() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 413), .clientSideError(.payloadTooLarge))
    }
    
    func testStatusCode414IsURITooLong() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 414), .clientSideError(.uriTooLong))
    }
    
    func testStatusCode415IsUnsupportedMediaType() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 415), .clientSideError(.unsupportedMediaType))
    }
    
    func testStatusCode416IsRangeNotSatisfiable() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 416), .clientSideError(.rangeNotSatisfiable))
    }
    
    func testStatusCode417IsExpectationFailed() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 417), .clientSideError(.expectationFailed))
    }
    
    func testStatusCode418IsImATeapot() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 418), .clientSideError(.imATeapot))
    }
    
    func testStatusCode421IsMisdirectedRequest() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 421), .clientSideError(.misdirectedRequest))
    }
    
    func testStatusCode422IsUnprocessableEntity() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 422), .clientSideError(.unprocessableEntity))
    }
    
    func testStatusCode423IsLocked() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 423), .clientSideError(.locked))
    }
    
    func testStatusCode424IsFailedDependency() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 424), .clientSideError(.failedDependency))
    }
    
    func testStatusCode425IsTooEarly() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 425), .clientSideError(.tooEarly))
    }
    
    func testStatusCode426IsUpgradeRequired() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 426), .clientSideError(.upgradeRequired))
    }
    
    func testStatusCode428IsPreconditionRequired() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 428), .clientSideError(.preconditionRequired))
    }
    
    func testStatusCode429IsTooManyRequests() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 429), .clientSideError(.tooManyRequests))
    }
    
    func testStatusCode431IsRequestHeaderFieldsTooLarge() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 431), .clientSideError(.requestHeaderFieldsTooLarge))
    }
    
    func testStatusCode451IsUnavailableForLegalReasons() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 451), .clientSideError(.unavailableForLegalReasons))
    }
    
    func testStatusCode500IsInternalServerError() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 500), .serverSideError(.internalServerError))
    }
    
    func testStatusCode501IsNotImplemented() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 501), .serverSideError(.notImplemented))
    }
    
    func testStatusCode502IsBadGateway() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 502), .serverSideError(.badGateway))
    }
    
    func testStatusCode503IsServiceUnavailable() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 503), .serverSideError(.serviceUnavailable))
    }
    
    func testStatusCode504IsGatewayTimeout() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 504), .serverSideError(.gatewayTimeout))
    }
    
    func testStatusCode505IsHttpVersionNotSupported() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 505), .serverSideError(.httpVersionNotSupported))
    }
    
    func testStatusCode506IsVariantAlsoNegotiates() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 506), .serverSideError(.variantAlsoNegotiates))
    }
    
    func testStatusCode507IsInsufficientStorage() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 507), .serverSideError(.insufficientStorage))
    }
    
    func testStatusCode508IsLoopDetected() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 508), .serverSideError(.loopDetected))
    }
    
    func testStatusCode510IsNotExtended() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 510), .serverSideError(.notExtended))
    }
    
    func testStatusCode511IsNetworkAuthenticationRequired() {
        XCTAssertEqual(HTTPStatusCodeType.evaluate(from: 511), .serverSideError(.networkAuthenticationRequired))
    }
}
