import Foundation

enum HTTPInformationalStatus: Error {
    static func description(from statusCode: Int) -> String {
        return HTTPInformationalStatus.descriptions[statusCode] ?? "Unknown Informational Status"
    }
    
    private static let descriptions: [Int: String] = [
        100: "Continue",
        101: "Switching Protocols",
        102: "Processing"
    ]
}
