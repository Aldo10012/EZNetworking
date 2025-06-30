@testable import EZNetworking
import Testing

@Suite("Test HTTPInformationalStatus")
final class HTTPInformationalStatusTests {
    @Test("test StatusCode 100 Is HTTPInformationalStatus.continueStatus")
    func testStatusCode100IsContinueStatus() {
        #expect(HTTPInformationalStatus(statusCode: 100) == .continueStatus)
    }
    @Test("test StatusCode 101 Is HTTPInformationalStatus.switchingProtocols")
    func testStatusCode101IsSwitchingProtocols() {
        #expect(HTTPInformationalStatus(statusCode: 101) == .switchingProtocols)
    }
    
    @Test("test StatusCode 102 Is HTTPInformationalStatus.processing")
    func testStatusCode102IsProcessing() {
        #expect(HTTPInformationalStatus(statusCode: 102) == .processing)
    }
    
    @Test("test StatusCode 103 Is HTTPInformationalStatus.unknown")
    func testStatusCode103IsUnknown() {
        #expect(HTTPInformationalStatus(statusCode: 103) == .unknown)
    }
}
