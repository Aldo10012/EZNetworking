@testable import EZNetworking
import Testing

@Suite("Test HTTPRedirectionStatus")
final class HTTPRedirectionStatusTests {
    @Test("test HTTPRedirectionStatus maps status code to description", arguments: zip(map.keys, map.values))
    func hTTPRedirectionStatusMapsStatusCodeToDescription(statusCode: Int, description: String) {
        #expect(HTTPRedirectionStatus.description(from: statusCode) == description)
    }

    private static let map: [Int: String] = [
        300: "Multiple Choices",
        301: "Moved Permanently",
        302: "Found",
        303: "See Other",
        304: "Not Modified",
        305: "Use Proxy",
        307: "Temporary Redirect",
        308: "Permanent Redirect",
        -1: "Unknown Redirection Status"
    ]
}
