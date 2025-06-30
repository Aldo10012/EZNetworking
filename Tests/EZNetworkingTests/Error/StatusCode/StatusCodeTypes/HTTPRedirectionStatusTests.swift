@testable import EZNetworking
import Testing

@Suite("Test HTTPRedirectionStatus")
final class HTTPRedirectionStatusTests {
    @Test("test StatusCode 300 HTTPRedirectionStatus.isMultipleChoices")
    func testStatusCode300IsMultipleChoices() {
        #expect(HTTPRedirectionStatus(statusCode: 300) == .multipleChoices)
    }
    @Test("test StatusCode 301 HTTPRedirectionStatus.movedPermanently")
    func testStatusCode301IsMovedPermanently() {
        #expect(HTTPRedirectionStatus(statusCode: 301) == .movedPermanently)
    }
    @Test("test StatusCode 302 HTTPRedirectionStatus.found")
    func testStatusCode302IsFound() {
        #expect(HTTPRedirectionStatus(statusCode: 302) == .found)
    }
    @Test("test StatusCode 303 HTTPRedirectionStatus.seeOther")
    func testStatusCode303IsSeeOther() {
        #expect(HTTPRedirectionStatus(statusCode: 303) == .seeOther)
    }
    @Test("test StatusCode 304 HTTPRedirectionStatus.notModified")
    func testStatusCode304IsNotModified() {
        #expect(HTTPRedirectionStatus(statusCode: 304) == .notModified)
    }
    @Test("test StatusCode 305 HTTPRedirectionStatus.useProxy")
    func testStatusCode305IsUseProxy() {
        #expect(HTTPRedirectionStatus(statusCode: 305) == .useProxy)
    }
    @Test("test StatusCode 307 HTTPRedirectionStatus.temporaryRedirect")
    func testStatusCode307IsTemporaryRedirect() {
        #expect(HTTPRedirectionStatus(statusCode: 307) == .temporaryRedirect)
    }
    @Test("test StatusCode 308 HTTPRedirectionStatus.permanentRedirect")
    func testStatusCode308IsPermanentRedirect() {
        #expect(HTTPRedirectionStatus(statusCode: 308) == .permanentRedirect)
    }
    @Test("test StatusCode 309 HTTPRedirectionStatus.unknown")
    func testStatusCode309IsUnknown() {
        #expect(HTTPRedirectionStatus(statusCode: 309) == .unknown)
    }
    @Test("test different HTTPNetworkingRedirectionErrors are not equatable")
    func testDifferentHTTPNetworkingRedirectionErrorsAreNotEquatable() {
        #expect(HTTPRedirectionStatus.found != HTTPRedirectionStatus.movedPermanently)
    }
}
