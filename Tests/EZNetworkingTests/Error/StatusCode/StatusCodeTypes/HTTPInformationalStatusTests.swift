import XCTest
@testable import EZNetworking

final class HTTPInformationalStatusTests: XCTestCase {
    func testStatusCode100IsContinueStatus() {
        XCTAssertEqual(HTTPInformationalStatus(statusCode: 100), .continueStatus)
    }
    
    func testStatusCode101IsSwitchingProtocols() {
        XCTAssertEqual(HTTPInformationalStatus(statusCode: 101), .switchingProtocols)
    }
    
    func testStatusCode102IsProcessing() {
        XCTAssertEqual(HTTPInformationalStatus(statusCode: 102), .processing)
    }
    
    func testStatusCode103IsUnknown() {
        XCTAssertEqual(HTTPInformationalStatus(statusCode: 103), .unknown)
    }
}
