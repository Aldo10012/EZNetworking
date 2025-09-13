@testable import EZNetworking
import Testing

@Suite("Test HTTPSuccessStatus")
final class HTTPSuccessStatusTests {

    @Test("test HTTPSuccessStatus maps status code to description", arguments: zip(map.keys, map.values))
    func testHTTPSuccessStatusMapsStatusCodeToDescription(statusCode: Int, description: String) {
        #expect(HTTPSuccessStatus.description(from: statusCode) == description)
    }

    private static let map: [Int: String] = [
        200: "OK",
        201: "Created",
        202: "Accepted",
        203: "Non-Authoritative Information",
        204: "No Content",
        205: "Reset Content",
        206: "Partial Content",
        207: "Multi-Status",
        208: "Already Reported",
        226: "IM Used",
         -1: "Unknown Success Status"
    ]
}
