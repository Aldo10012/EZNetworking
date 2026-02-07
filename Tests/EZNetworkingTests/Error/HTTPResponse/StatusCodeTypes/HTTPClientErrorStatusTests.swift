@testable import EZNetworking
import Testing

@Suite("Test HTTPClientErrorStatus")
final class HTTPClientErrorStatusTests {
    @Test("test HTTPClientErrorStatus maps status code to description", arguments: zip(map.keys, map.values))
    func hTTPClientErrorStatusMapsStatusCodeToDescription(statusCode: Int, description: String) {
        #expect(HTTPClientErrorStatus.description(from: statusCode) == description)
    }

    private static let map: [Int: String] = [
        400: "Bad Request",
        401: "Unauthorized",
        402: "Payment Required",
        403: "Forbidden",
        404: "Not Found",
        405: "Method Not Allowed",
        406: "Not Acceptable",
        407: "Proxy Authentication Required",
        408: "Request Timeout",
        409: "Conflict",
        410: "Gone",
        411: "Length Required",
        412: "Precondition Failed",
        413: "Payload Too Large",
        414: "URI Too Long",
        415: "Unsupported Media Type",
        416: "Range Not Satisfiable",
        417: "Expectation Failed",
        418: "I'm a teapot",
        421: "Misdirected Request",
        422: "Unprocessable Entity",
        423: "Locked",
        424: "Failed Dependency",
        425: "Too Early",
        426: "Upgrade Required",
        428: "Precondition Required",
        429: "Too Many Requests",
        431: "Request Header Fields Too Large",
        451: "Unavailable For Legal Reasons",
        -1: "Unknown Client Error"
    ]
}
