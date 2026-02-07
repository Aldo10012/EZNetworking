import Foundation

public struct HTTPResponse: Sendable {
    public let statusCode: Int
    public let headers: [String: String]
    public let category: HTTPErrorCategory

    public init(statusCode: Int, headers: [String: String] = [:]) {
        self.statusCode = statusCode
        self.headers = headers
        category = HTTPErrorCategory.from(statusCode: statusCode)
    }

    public var description: String {
        switch category {
        case .informational:
            HTTPInformationalStatus.description(from: statusCode)
        case .success:
            HTTPSuccessStatus.description(from: statusCode)
        case .redirection:
            HTTPRedirectionStatus.description(from: statusCode)
        case .clientError:
            HTTPClientErrorStatus.description(from: statusCode)
        case .serverError:
            HTTPServerErrorStatus.description(from: statusCode)
        case .unknown:
            "Unknown Status Code (\(statusCode))"
        }
    }

    public enum HTTPErrorCategory: Sendable {
        case informational // 1xx
        case success // 2xx
        case redirection // 3xx
        case clientError // 4xx
        case serverError // 5xx
        case unknown // Other

        static func from(statusCode: Int) -> HTTPErrorCategory {
            switch statusCode {
            case 100 ... 199: .informational
            case 200 ... 299: .success
            case 300 ... 399: .redirection
            case 400 ... 499: .clientError
            case 500 ... 599: .serverError
            default: .unknown
            }
        }
    }
}
