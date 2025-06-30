@testable import EZNetworking
import Testing

@Suite("Test HTTPInformationalStatus")
final class HTTPInformationalStatusTests {

    @Test("test status code maps correctly to HTTPInformationalStatus", arguments: zip(map.keys, map.values))
    func testStatusCodeMapsCorrectlyToHTTPInformationalStatus(statusCode: Int, status: HTTPInformationalStatus) {
        #expect(HTTPInformationalStatus(statusCode: statusCode) == status)
    }

    private static let map: [Int: HTTPInformationalStatus] = [
        100: HTTPInformationalStatus.continueStatus,
        101: HTTPInformationalStatus.switchingProtocols,
        102: HTTPInformationalStatus.processing,
        -1: HTTPInformationalStatus.unknown
    ]
}
