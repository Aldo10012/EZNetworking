@testable import EZNetworking
import Testing

@Suite("Test HTTPServerErrorStatus")
final class HTTPServerErrorStatusTests {
    @Test("test HTTPServerErrorStatus maps status code to description", arguments: zip(map.keys, map.values))
    func hTTPServerErrorStatusMapsStatusCodeToDescription(statusCode: Int, description: String) {
        #expect(HTTPServerErrorStatus.description(from: statusCode) == description)
    }

    private static let map: [Int: String] = [
        500: "Internal Server Error",
        501: "Not Implemented",
        502: "Bad Gateway",
        503: "Service Unavailable",
        504: "Gateway Timeout",
        505: "HTTP Version Not Supported",
        506: "Variant Also Negotiates",
        507: "Insufficient Storage",
        508: "Loop Detected",
        510: "Not Extended",
        511: "Network Authentication Required",
        -1: "Unknown Server Error"
    ]
}
