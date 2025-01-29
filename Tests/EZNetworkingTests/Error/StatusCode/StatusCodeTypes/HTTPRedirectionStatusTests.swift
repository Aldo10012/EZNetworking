import XCTest
@testable import EZNetworking

final class HTTPRedirectionStatusTests: XCTestCase {
    
    func testStatusCode300IsMultipleChoices() {
        XCTAssertEqual(HTTPRedirectionStatus(statusCode: 300), .multipleChoices)
    }
    
    func testStatusCode301IsMovedPermanently() {
        XCTAssertEqual(HTTPRedirectionStatus(statusCode: 301), .movedPermanently)
    }
    
    func testStatusCode302IsFound() {
        XCTAssertEqual(HTTPRedirectionStatus(statusCode: 302), .found)
    }
    
    func testStatusCode303IsSeeOther() {
        XCTAssertEqual(HTTPRedirectionStatus(statusCode: 303), .seeOther)
    }
    
    func testStatusCode304IsNotModified() {
        XCTAssertEqual(HTTPRedirectionStatus(statusCode: 304), .notModified)
    }
    
    func testStatusCode305IsUseProxy() {
        XCTAssertEqual(HTTPRedirectionStatus(statusCode: 305), .useProxy)
    }
    
    func testStatusCode307IsTemporaryRedirect() {
        XCTAssertEqual(HTTPRedirectionStatus(statusCode: 307), .temporaryRedirect)
    }
    
    func testStatusCode308IsPermanentRedirect() {
        XCTAssertEqual(HTTPRedirectionStatus(statusCode: 308), .permanentRedirect)
    }
    
    func testStatusCode309IsUnknown() {
        XCTAssertEqual(HTTPRedirectionStatus(statusCode: 309), .unknown)
    }
    
    func testDifferentHTTPNetworkingRedirectionErrorsAreNotEquatable() {
        XCTAssertNotEqual(HTTPRedirectionStatus.found, HTTPRedirectionStatus.movedPermanently)
    }
}
