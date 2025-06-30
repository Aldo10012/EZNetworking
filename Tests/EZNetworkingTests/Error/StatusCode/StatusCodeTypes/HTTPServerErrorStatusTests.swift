@testable import EZNetworking
import Testing

@Suite("Test HTTPServerErrorStatus")
final class HTTPServerErrorStatusTests {
    @Test("test StatusCode 500 Is HTTPServerErrorStatus.internalServerError")
    func testStatusCode500IsInternalServerError() {
        #expect(HTTPServerErrorStatus(statusCode: 500) == .internalServerError)
    }
    @Test("test StatusCode 501 Is HTTPServerErrorStatus.notImplemented")
    func testStatusCode501IsNotImplemented() {
        #expect(HTTPServerErrorStatus(statusCode: 501) == .notImplemented)
    }
    @Test("test StatusCode 502 Is HTTPServerErrorStatus.badGateway")
    func testStatusCode502IsBadGateway() {
        #expect(HTTPServerErrorStatus(statusCode: 502) == .badGateway)
    }
    @Test("test StatusCode 503 Is HTTPServerErrorStatus.serviceUnavailable")
    func testStatusCode503IsServiceUnavailable() {
        #expect(HTTPServerErrorStatus(statusCode: 503) == .serviceUnavailable)
    }
    @Test("test StatusCode 504 Is HTTPServerErrorStatus.gatewayTimeout")
    func testStatusCode504IsGatewayTimeout() {
        #expect(HTTPServerErrorStatus(statusCode: 504) == .gatewayTimeout)
    }
    @Test("test StatusCode 505 Is HTTPServerErrorStatus.httpVersionNotSupported")
    func testStatusCode505IsHttpVersionNotSupported() {
        #expect(HTTPServerErrorStatus(statusCode: 505) == .httpVersionNotSupported)
    }
    @Test("test StatusCode 506 Is HTTPServerErrorStatus.variantAlsoNegotiates")
    func testStatusCode506IsVariantAlsoNegotiates() {
        #expect(HTTPServerErrorStatus(statusCode: 506) == .variantAlsoNegotiates)
    }
    @Test("test StatusCode 507 Is HTTPServerErrorStatus.insufficientStorage")
    func testStatusCode507IsInsufficientStorage() {
        #expect(HTTPServerErrorStatus(statusCode: 507) == .insufficientStorage)
    }
    @Test("test StatusCode 508 Is HTTPServerErrorStatus.loopDetected")
    func testStatusCode508IsLoopDetected() {
        #expect(HTTPServerErrorStatus(statusCode: 508) == .loopDetected)
    }
    @Test("test StatusCode 510 Is HTTPServerErrorStatus.notExtended")
    func testStatusCode510IsNotExtended() {
        #expect(HTTPServerErrorStatus(statusCode: 510) == .notExtended)
    }
    @Test("test StatusCode 511 Is HTTPServerErrorStatus.networkAuthenticationRequired")
    func testStatusCode511IsNetworkAuthenticationRequired() {
        #expect(HTTPServerErrorStatus(statusCode: 511) == .networkAuthenticationRequired)
    }
    @Test("test StatusCode 512 Is HTTPServerErrorStatus.unknown")
    func testStatusCode511IsUnknown() {
        #expect(HTTPServerErrorStatus(statusCode: 512) == .unknown)
    }
    @Test("test different HTTPNetworkingServerErrors are not equatable")
    func testDifferentHTTPNetworkingServerErrorsAreNotEquatable() {
        #expect(HTTPServerErrorStatus.badGateway != HTTPServerErrorStatus.gatewayTimeout)
    }
}
