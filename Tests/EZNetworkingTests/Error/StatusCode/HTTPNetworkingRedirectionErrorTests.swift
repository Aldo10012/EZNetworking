import XCTest
@testable import EZNetworking

final class HTTPNetworkingRedirectionErrorTests: XCTestCase {
    
    func testStatusCode300IsMultipleChoices() {
        XCTAssertEqual(HTTPNetworkingRedirectionError.fromStatusCode(300), .multipleChoices)
    }
    
    func testStatusCode301IsMovedPermanently() {
        XCTAssertEqual(HTTPNetworkingRedirectionError.fromStatusCode(301), .movedPermanently)
    }
    
    func testStatusCode302IsFound() {
        XCTAssertEqual(HTTPNetworkingRedirectionError.fromStatusCode(302), .found)
    }
    
    func testStatusCode303IsSeeOther() {
        XCTAssertEqual(HTTPNetworkingRedirectionError.fromStatusCode(303), .seeOther)
    }
    
    func testStatusCode304IsNotModified() {
        XCTAssertEqual(HTTPNetworkingRedirectionError.fromStatusCode(304), .notModified)
    }
    
    func testStatusCode305IsUseProxy() {
        XCTAssertEqual(HTTPNetworkingRedirectionError.fromStatusCode(305), .useProxy)
    }
    
    func testStatusCode307IsTemporaryRedirect() {
        XCTAssertEqual(HTTPNetworkingRedirectionError.fromStatusCode(307), .temporaryRedirect)
    }
    
    func testStatusCode308IsPermanentRedirect() {
        XCTAssertEqual(HTTPNetworkingRedirectionError.fromStatusCode(308), .permanentRedirect)
    }
    
}
