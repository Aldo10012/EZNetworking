import Foundation

enum HTTPSuccessStatus {
    static func description(from statusCode: Int) -> String {
        HTTPSuccessStatus.descriptions[statusCode] ?? "Unknown Success Status"
    }

    private static let descriptions: [Int: String] = [
        200: "OK",
        201: "Created",
        202: "Accepted",
        203: "Non-Authoritative Information",
        204: "No Content",
        205: "Reset Content",
        206: "Partial Content",
        207: "Multi-Status",
        208: "Already Reported",
        226: "IM Used"
    ]
}
