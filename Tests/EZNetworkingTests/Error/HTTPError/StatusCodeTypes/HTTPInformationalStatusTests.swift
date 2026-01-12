import Testing
@testable import EZNetworking

@Suite("Test HTTPInformationalStatus")
final class HTTPInformationalStatusTests {
    @Test("test HTTPInformationalStatus maps status code to description", arguments: zip(map.keys, map.values))
    func hTTPInformationalStatusMapsStatusCodeToDescription(statusCode: Int, description: String) {
        #expect(HTTPInformationalStatus.description(from: statusCode) == description)
    }

    private static let map: [Int: String] = [
        100: "Continue",
        101: "Switching Protocols",
        102: "Processing",
        -1: "Unknown Informational Status"
    ]
}
