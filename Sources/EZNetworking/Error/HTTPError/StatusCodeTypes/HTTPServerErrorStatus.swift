import Foundation

enum HTTPServerErrorStatus: Error {
    static func description(from statusCode: Int) -> String {
        HTTPServerErrorStatus.descriptions[statusCode] ?? "Unknown Server Error"
    }

    private static let descriptions: [Int: String] = [
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
        511: "Network Authentication Required"
    ]
}
