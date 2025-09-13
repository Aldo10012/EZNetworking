@testable import EZNetworking
import Testing

@Suite("Test HTTPRedirectionStatus")
final class HTTPRedirectionStatusTests {

    @Test("test status code maps correctly to HTTPRedirectionStatus", arguments: zip(map.keys, map.values))
    func testStatusCodeMapsCorrectlyToHTTPRedirectionStatus(statusCode: Int, status: HTTPRedirectionStatus) {
        #expect(HTTPRedirectionStatus(statusCode: statusCode) == status)
    }

    private static let map: [Int: HTTPRedirectionStatus] = [
        300: HTTPRedirectionStatus.multipleChoices,
        301: HTTPRedirectionStatus.movedPermanently,
        302: HTTPRedirectionStatus.found,
        303: HTTPRedirectionStatus.seeOther,
        304: HTTPRedirectionStatus.notModified,
        305: HTTPRedirectionStatus.useProxy,
        307: HTTPRedirectionStatus.temporaryRedirect,
        308: HTTPRedirectionStatus.permanentRedirect,
        -1: HTTPRedirectionStatus.unknown
    ]
}
