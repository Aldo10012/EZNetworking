import XCTest
@testable import EZNetworking

final class HTTPNetworkingRedirectionErrorTests: XCTestCase {
    
    func testStatusCode300IsMultipleChoices() {
        XCTAssertEqual(HTTPNetworkingRedirectionError(statusCode: 300), .multipleChoices)
    }
    
    func testStatusCode301IsMovedPermanently() {
        XCTAssertEqual(HTTPNetworkingRedirectionError(statusCode: 301), .movedPermanently)
    }
    
    func testStatusCode302IsFound() {
        XCTAssertEqual(HTTPNetworkingRedirectionError(statusCode: 302), .found)
    }
    
    func testStatusCode303IsSeeOther() {
        XCTAssertEqual(HTTPNetworkingRedirectionError(statusCode: 303), .seeOther)
    }
    
    func testStatusCode304IsNotModified() {
        XCTAssertEqual(HTTPNetworkingRedirectionError(statusCode: 304), .notModified)
    }
    
    func testStatusCode305IsUseProxy() {
        XCTAssertEqual(HTTPNetworkingRedirectionError(statusCode: 305), .useProxy)
    }
    
    func testStatusCode307IsTemporaryRedirect() {
        XCTAssertEqual(HTTPNetworkingRedirectionError(statusCode: 307), .temporaryRedirect)
    }
    
    func testStatusCode308IsPermanentRedirect() {
        XCTAssertEqual(HTTPNetworkingRedirectionError(statusCode: 308), .permanentRedirect)
    }
    
    func testStatusCode309IsUnknown() {
        XCTAssertEqual(HTTPNetworkingRedirectionError(statusCode: 309), .unknown)
    }
    
}
