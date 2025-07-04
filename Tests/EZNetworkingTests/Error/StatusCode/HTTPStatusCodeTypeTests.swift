@testable import EZNetworking
import Testing

@Suite("Test HTTPStatusCodeType")
final class HTTPStatusCodeTypeTests {

    @Test("test status code maps correctly to HTTPStatusCodeType", arguments: zip(map.keys, map.values))
    func testStatusCodeMapsCorrectlyToHTTPStatusCodeType(statusCode: Int, statysCodeType: HTTPStatusCodeType) {
        #expect(HTTPStatusCodeType.evaluate(from: statusCode) == statysCodeType)
    }
    
    private static let map: [Int: HTTPStatusCodeType] = [
        // 1xx status code
        100: HTTPStatusCodeType.information(.continueStatus),
        101: HTTPStatusCodeType.information(.switchingProtocols),
        102: HTTPStatusCodeType.information(.processing),

        // 2xx status code
        200: HTTPStatusCodeType.success(.ok),
        201: HTTPStatusCodeType.success(.created),
        202: HTTPStatusCodeType.success(.accepted),
        203: HTTPStatusCodeType.success(.nonAuthoritativeInformation),
        204: HTTPStatusCodeType.success(.noContent),
        205: HTTPStatusCodeType.success(.resetContent),
        206: HTTPStatusCodeType.success(.partialContent),
        207: HTTPStatusCodeType.success(.multiStatus),
        208: HTTPStatusCodeType.success(.alreadyReported),
        226: HTTPStatusCodeType.success(.iMUsed),

        // 3xx status code
        300: HTTPStatusCodeType.redirectionMessage(.multipleChoices),
        301: HTTPStatusCodeType.redirectionMessage(.movedPermanently),
        302: HTTPStatusCodeType.redirectionMessage(.found),
        303: HTTPStatusCodeType.redirectionMessage(.seeOther),
        304: HTTPStatusCodeType.redirectionMessage(.notModified),
        305: HTTPStatusCodeType.redirectionMessage(.useProxy),
        307: HTTPStatusCodeType.redirectionMessage(.temporaryRedirect),
        308: HTTPStatusCodeType.redirectionMessage(.permanentRedirect),

        // 4xx status code
        400: HTTPStatusCodeType.clientSideError(.badRequest),
        401: HTTPStatusCodeType.clientSideError(.unauthorized),
        402: HTTPStatusCodeType.clientSideError(.paymentRequired),
        403: HTTPStatusCodeType.clientSideError(.forbidden),
        404: HTTPStatusCodeType.clientSideError(.notFound),
        405: HTTPStatusCodeType.clientSideError(.methodNotAllowed),
        406: HTTPStatusCodeType.clientSideError(.notAcceptable),
        407: HTTPStatusCodeType.clientSideError(.proxyAuthenticationRequired),
        408: HTTPStatusCodeType.clientSideError(.requestTimeout),
        409: HTTPStatusCodeType.clientSideError(.conflict),
        410: HTTPStatusCodeType.clientSideError(.gone),
        411: HTTPStatusCodeType.clientSideError(.lengthRequired),
        412: HTTPStatusCodeType.clientSideError(.preconditionFailed),
        413: HTTPStatusCodeType.clientSideError(.payloadTooLarge),
        414: HTTPStatusCodeType.clientSideError(.uriTooLong),
        415: HTTPStatusCodeType.clientSideError(.unsupportedMediaType),
        416: HTTPStatusCodeType.clientSideError(.rangeNotSatisfiable),
        417: HTTPStatusCodeType.clientSideError(.expectationFailed),
        418: HTTPStatusCodeType.clientSideError(.imATeapot),
        421: HTTPStatusCodeType.clientSideError(.misdirectedRequest),
        422: HTTPStatusCodeType.clientSideError(.unprocessableEntity),
        423: HTTPStatusCodeType.clientSideError(.locked),
        424: HTTPStatusCodeType.clientSideError(.failedDependency),
        425: HTTPStatusCodeType.clientSideError(.tooEarly),
        426: HTTPStatusCodeType.clientSideError(.upgradeRequired),
        428: HTTPStatusCodeType.clientSideError(.preconditionRequired),
        429: HTTPStatusCodeType.clientSideError(.tooManyRequests),
        431: HTTPStatusCodeType.clientSideError(.requestHeaderFieldsTooLarge),
        451: HTTPStatusCodeType.clientSideError(.unavailableForLegalReasons),

        // 5xx status code
        500: HTTPStatusCodeType.serverSideError(.internalServerError),
        501: HTTPStatusCodeType.serverSideError(.notImplemented),
        502: HTTPStatusCodeType.serverSideError(.badGateway),
        503: HTTPStatusCodeType.serverSideError(.serviceUnavailable),
        504: HTTPStatusCodeType.serverSideError(.gatewayTimeout),
        505: HTTPStatusCodeType.serverSideError(.httpVersionNotSupported),
        506: HTTPStatusCodeType.serverSideError(.variantAlsoNegotiates),
        507: HTTPStatusCodeType.serverSideError(.insufficientStorage),
        508: HTTPStatusCodeType.serverSideError(.loopDetected),
        510: HTTPStatusCodeType.serverSideError(.notExtended),
        511: HTTPStatusCodeType.serverSideError(.networkAuthenticationRequired)
    ]
}
