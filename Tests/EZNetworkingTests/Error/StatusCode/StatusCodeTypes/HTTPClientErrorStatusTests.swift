@testable import EZNetworking
import Testing

@Suite("Test HTTPClientErrorStatus")
final class HTTPClientErrorStatusTests {
    @Test("test status code 400 is HTTPClientErrorStatus.badRequest")
    func testStatusCode400IsBadRequest() {
        #expect(HTTPClientErrorStatus(statusCode: 400) == .badRequest)
    }
    @Test("test status code 401 is HTTPClientErrorStatus.unauthorized")
    func testStatusCode401IsUnauthorized() {
        #expect(HTTPClientErrorStatus(statusCode: 401) == .unauthorized)
    }
    @Test("test status code 402 is HTTPClientErrorStatus.paymentRequired")
    func testStatusCode402IsPaymentRequired() {
        #expect(HTTPClientErrorStatus(statusCode: 402) == .paymentRequired)
    }
    @Test("test status code 403 is HTTPClientErrorStatus.forbidden")
    func testStatusCode403IsForbidden() {
        #expect(HTTPClientErrorStatus(statusCode: 403) == .forbidden)
    }
    @Test("test status code 404 is HTTPClientErrorStatus.notFound")
    func testStatusCode404IsNotFound() {
        #expect(HTTPClientErrorStatus(statusCode: 404) == .notFound)
    }
    @Test("test status code 405 is HTTPClientErrorStatus.methodNotAllowed")
    func testStatusCode405IsMethodNotAllowed() {
        #expect(HTTPClientErrorStatus(statusCode: 405) == .methodNotAllowed)
    }
    @Test("test status code 406 is HTTPClientErrorStatus.notAcceptable")
    func testStatusCode406IsNotAcceptable() {
        #expect(HTTPClientErrorStatus(statusCode: 406) == .notAcceptable)
    }
    @Test("test status code 407 is HTTPClientErrorStatus.proxyAuthenticationRequired")
    func testStatusCode407IsProxyAuthenticationRequired() {
        #expect(HTTPClientErrorStatus(statusCode: 407) == .proxyAuthenticationRequired)
    }
    @Test("test status code 408 is HTTPClientErrorStatus.requestTimeout")
    func testStatusCode408IsRequestTimeout() {
        #expect(HTTPClientErrorStatus(statusCode: 408) == .requestTimeout)
    }
    @Test("test status code 409 is HTTPClientErrorStatus.conflict")
    func testStatusCode409IsConflict() {
        #expect(HTTPClientErrorStatus(statusCode: 409) == .conflict)
    }
    @Test("test status code 410 is HTTPClientErrorStatus.gone")
    func testStatusCode410IsGone() {
        #expect(HTTPClientErrorStatus(statusCode: 410) == .gone)
    }
    @Test("test status code 411 is HTTPClientErrorStatus.lengthRequired")
    func testStatusCode411IsLengthRequired() {
        #expect(HTTPClientErrorStatus(statusCode: 411) == .lengthRequired)
    }
    @Test("test status code 412 is HTTPClientErrorStatus.preconditionFailed")
    func testStatusCode412IsPreconditionFailed() {
        #expect(HTTPClientErrorStatus(statusCode: 412) == .preconditionFailed)
    }
    @Test("test status code 413 is HTTPClientErrorStatus.payloadTooLarge")
    func testStatusCode413IsPayloadTooLarge() {
        #expect(HTTPClientErrorStatus(statusCode: 413) == .payloadTooLarge)
    }
    @Test("test status code 414 is HTTPClientErrorStatus.uriTooLong")
    func testStatusCode414IsURITooLong() {
        #expect(HTTPClientErrorStatus(statusCode: 414) == .uriTooLong)
    }
    @Test("test status code 415 is HTTPClientErrorStatus.unsupportedMediaType")
    func testStatusCode415IsUnsupportedMediaType() {
        #expect(HTTPClientErrorStatus(statusCode: 415) == .unsupportedMediaType)
    }
    @Test("test status code 416 is HTTPClientErrorStatus.rangeNotSatisfiable")
    func testStatusCode416IsRangeNotSatisfiable() {
        #expect(HTTPClientErrorStatus(statusCode: 416) == .rangeNotSatisfiable)
    }
    @Test("test status code 417 is HTTPClientErrorStatus.expectationFailed")
    func testStatusCode417IsExpectationFailed() {
        #expect(HTTPClientErrorStatus(statusCode: 417) == .expectationFailed)
    }
    @Test("test status code 418 is HTTPClientErrorStatus.imATeapot")
    func testStatusCode418IsImATeapot() {
        #expect(HTTPClientErrorStatus(statusCode: 418) == .imATeapot)
    }
    @Test("test status code 421 is HTTPClientErrorStatus.misdirectedRequest")
    func testStatusCode421IsMisdirectedRequest() {
        #expect(HTTPClientErrorStatus(statusCode: 421) == .misdirectedRequest)
    }
    @Test("test status code 422 is HTTPClientErrorStatus.unprocessableEntity")
    func testStatusCode422IsUnprocessableEntity() {
        #expect(HTTPClientErrorStatus(statusCode: 422) == .unprocessableEntity)
    }
    @Test("test status code 423 is HTTPClientErrorStatus.locked")
    func testStatusCode423IsLocked() {
        #expect(HTTPClientErrorStatus(statusCode: 423) == .locked)
    }
    @Test("test status code 424 is HTTPClientErrorStatus.failedDependency")
    func testStatusCode424IsFailedDependency() {
        #expect(HTTPClientErrorStatus(statusCode: 424) == .failedDependency)
    }
    @Test("test status code 425 is HTTPClientErrorStatus.tooEarly")
    func testStatusCode425IsTooEarly() {
        #expect(HTTPClientErrorStatus(statusCode: 425) == .tooEarly)
    }
    @Test("test status code 426 is HTTPClientErrorStatus.upgradeRequired")
    func testStatusCode426IsUpgradeRequired() {
        #expect(HTTPClientErrorStatus(statusCode: 426) == .upgradeRequired)
    }
    @Test("test status code 428 is HTTPClientErrorStatus.preconditionRequired")
    func testStatusCode428IsPreconditionRequired() {
        #expect(HTTPClientErrorStatus(statusCode: 428) == .preconditionRequired)
    }
    @Test("test status code 429 is HTTPClientErrorStatus.tooManyRequests")
    func testStatusCode429IsTooManyRequests() {
        #expect(HTTPClientErrorStatus(statusCode: 429) == .tooManyRequests)
    }
    @Test("test status code 431 is HTTPClientErrorStatus.requestHeaderFieldsTooLarge")
    func testStatusCode431IsRequestHeaderFieldsTooLarge() {
        #expect(HTTPClientErrorStatus(statusCode: 431) == .requestHeaderFieldsTooLarge)
    }
    @Test("test status code 451 is HTTPClientErrorStatus.unavailableForLegalReasons")
    func testStatusCode451IsUnavailableForLegalReasons() {
        #expect(HTTPClientErrorStatus(statusCode: 451) == .unavailableForLegalReasons)
    }
    @Test("test status code 452 is HTTPClientErrorStatus.unknown")
    func testStatusCode451IsUnknowns() {
        #expect(HTTPClientErrorStatus(statusCode: 452) == .unknown)
    }
    @Test("test Different HTTPNetworkingClientErrors Are Not Equatable")
    func testDifferentHTTPNetworkingClientErrorsAreNotEquatable() {
        #expect(HTTPClientErrorStatus.badRequest != HTTPClientErrorStatus.conflict)
    }
}
