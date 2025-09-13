@testable import EZNetworking
import Testing

@Suite("Test HTTPSuccessStatus")
final class HTTPSuccessStatusTests {

    @Test("test status code maps correctly to HTTPSuccessStatus", arguments: zip(map.keys, map.values))
    func testStatusCodeMapsCorrectlyToHTTPSuccessStatus(statusCode: Int, status: HTTPSuccessStatus) {
        #expect(HTTPSuccessStatus(statusCode: statusCode) == status)
    }

    private static let map: [Int: HTTPSuccessStatus] = [
        200: HTTPSuccessStatus.ok,
        201: HTTPSuccessStatus.created,
        202: HTTPSuccessStatus.accepted,
        203: HTTPSuccessStatus.nonAuthoritativeInformation,
        204: HTTPSuccessStatus.noContent,
        205: HTTPSuccessStatus.resetContent,
        206: HTTPSuccessStatus.partialContent,
        207: HTTPSuccessStatus.multiStatus,
        208: HTTPSuccessStatus.alreadyReported,
        226: HTTPSuccessStatus.iMUsed,
        -1: HTTPSuccessStatus.unknown
    ]
}
