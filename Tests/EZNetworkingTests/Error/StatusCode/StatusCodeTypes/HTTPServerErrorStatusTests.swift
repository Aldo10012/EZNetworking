@testable import EZNetworking
import Testing

@Suite("Test HTTPServerErrorStatus")
final class HTTPServerErrorStatusTests {

    @Test("test status code maps correctly to HTTPServerErrorStatus", arguments: zip(map.keys, map.values))
    func testStatusCodeMapsCorrectlyToHTTPServerErrorStatus(statusCode: Int, status: HTTPServerErrorStatus) {
        #expect(HTTPServerErrorStatus(statusCode: statusCode) == status)
    }

    private static let map = [
        500: HTTPServerErrorStatus.internalServerError,
        501: HTTPServerErrorStatus.notImplemented,
        502: HTTPServerErrorStatus.badGateway,
        503: HTTPServerErrorStatus.serviceUnavailable,
        504: HTTPServerErrorStatus.gatewayTimeout,
        505: HTTPServerErrorStatus.httpVersionNotSupported,
        506: HTTPServerErrorStatus.variantAlsoNegotiates,
        507: HTTPServerErrorStatus.insufficientStorage,
        508: HTTPServerErrorStatus.loopDetected,
        510: HTTPServerErrorStatus.notExtended,
        511: HTTPServerErrorStatus.networkAuthenticationRequired,
        -1: HTTPServerErrorStatus.unknown
    ]
}
