@testable import EZNetworking
import Testing

@Suite("Test HTTPClientErrorStatus")
final class HTTPClientErrorStatusTests {

    @Test("test status code maps correctly to HTTPClientErrorStatus",
          arguments: zip(map.keys, map.values))
    func testStatusCodeMapsCorrectlyToHTTPClientErrorStatus(statusCode: Int, status: HTTPClientErrorStatus) {
        #expect(HTTPClientErrorStatus(statusCode: statusCode) == status)
    }

    private static let map: [Int: HTTPClientErrorStatus] = [
        400: HTTPClientErrorStatus.badRequest,
        401: HTTPClientErrorStatus.unauthorized,
        402: HTTPClientErrorStatus.paymentRequired,
        403: HTTPClientErrorStatus.forbidden,
        404: HTTPClientErrorStatus.notFound,
        405: HTTPClientErrorStatus.methodNotAllowed,
        406: HTTPClientErrorStatus.notAcceptable,
        407: HTTPClientErrorStatus.proxyAuthenticationRequired,
        408: HTTPClientErrorStatus.requestTimeout,
        409: HTTPClientErrorStatus.conflict,
        410: HTTPClientErrorStatus.gone,
        411: HTTPClientErrorStatus.lengthRequired,
        412: HTTPClientErrorStatus.preconditionFailed,
        413: HTTPClientErrorStatus.payloadTooLarge,
        414: HTTPClientErrorStatus.uriTooLong,
        415: HTTPClientErrorStatus.unsupportedMediaType,
        416: HTTPClientErrorStatus.rangeNotSatisfiable,
        417: HTTPClientErrorStatus.expectationFailed,
        418: HTTPClientErrorStatus.imATeapot,
        421: HTTPClientErrorStatus.misdirectedRequest,
        422: HTTPClientErrorStatus.unprocessableEntity,
        423: HTTPClientErrorStatus.locked,
        424: HTTPClientErrorStatus.failedDependency,
        425: HTTPClientErrorStatus.tooEarly,
        426: HTTPClientErrorStatus.upgradeRequired,
        428: HTTPClientErrorStatus.preconditionRequired,
        429: HTTPClientErrorStatus.tooManyRequests,
        431: HTTPClientErrorStatus.requestHeaderFieldsTooLarge,
        451: HTTPClientErrorStatus.unavailableForLegalReasons,
        -1:  HTTPClientErrorStatus.unknown
    ]
}
