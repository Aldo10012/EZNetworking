import Foundation

enum HTTPRedirectionStatus: Error {
    static func description(from statusCode: Int) -> String {
        return HTTPRedirectionStatus.descriptions[statusCode] ?? "Unknown Redirection Status"
    }

    private static let descriptions: [Int: String] = [
        300: "Multiple Choices",
        301: "Moved Permanently",
        302: "Found",
        303: "See Other",
        304: "Not Modified",
        305: "Use Proxy",
        307: "Temporary Redirect",
        308: "Permanent Redirect"
    ]
}
