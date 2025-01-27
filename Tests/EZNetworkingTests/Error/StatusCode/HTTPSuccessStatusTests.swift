import XCTest
@testable import EZNetworking

final class HTTPSuccessStatusTests: XCTestCase {
    
    func testStatusCode200IsOk() {
        XCTAssertEqual(HTTPSuccessStatus(statusCode: 200), .ok)
    }
    
    func testStatusCode201IsCreated() {
        XCTAssertEqual(HTTPSuccessStatus(statusCode: 201), .created)
    }
    
    func testStatusCode202IsAccepted() {
        XCTAssertEqual(HTTPSuccessStatus(statusCode: 202), .accepted)
    }
    
    func testStatusCode203IsNonAuthoritativeInformation() {
        XCTAssertEqual(HTTPSuccessStatus(statusCode: 203), .nonAuthoritativeInformation)
    }
    
    func testStatusCode204IsNoContent() {
        XCTAssertEqual(HTTPSuccessStatus(statusCode: 204), .noContent)
    }
    
    func testStatusCode205IsResetContent() {
        XCTAssertEqual(HTTPSuccessStatus(statusCode: 205), .resetContent)
    }
    
    func testStatusCode206IsPartialContent() {
        XCTAssertEqual(HTTPSuccessStatus(statusCode: 206), .partialContent)
    }
    
    func testStatusCode207IsMultiStatus() {
        XCTAssertEqual(HTTPSuccessStatus(statusCode: 207), .multiStatus)
    }
    
    func testStatusCode208IsAlreadyReported() {
        XCTAssertEqual(HTTPSuccessStatus(statusCode: 208), .alreadyReported)
    }
    
    func testStatusCode226IsiMUsed() {
        XCTAssertEqual(HTTPSuccessStatus(statusCode: 226), .iMUsed)
    }
    
    func testStatusCode210IsUnknown() {
        XCTAssertEqual(HTTPSuccessStatus(statusCode: 210), .unknown)
    }
}
