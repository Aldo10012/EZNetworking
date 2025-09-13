import Foundation

public enum HTTPStatusCodeType: Equatable {
    case information(HTTPInformationalStatus)        // 1xx informational
    case success(HTTPSuccessStatus)                  // 2xx success
    case redirectionMessage(HTTPRedirectionStatus)   // 3xx redirect message
    case clientSideError(HTTPClientErrorStatus)      // 4xx client errors
    case serverSideError(HTTPServerErrorStatus)      // 5xx server errors
    case unknown
    
    public static func evaluate(from statusCode: Int) -> HTTPStatusCodeType {
        return switch statusCode {
        case 100...199: .information(HTTPInformationalStatus(statusCode: statusCode))
        case 200...299: .success(HTTPSuccessStatus(statusCode: statusCode))
        case 300...399: .redirectionMessage(HTTPRedirectionStatus(statusCode: statusCode))
        case 400...499: .clientSideError(HTTPClientErrorStatus(statusCode: statusCode))
        case 500...599: .serverSideError(HTTPServerErrorStatus(statusCode: statusCode))
        default: .unknown
        }
    }
}

// TODO: move to another file

public struct HTTPError: Error {
    public let statusCode: Int
    public let headers: [AnyHashable: Any]
    public let category: HTTPErrorCategory
    
    public init(statusCode: Int, headers: [AnyHashable: Any]) {
        self.statusCode = statusCode
        self.headers = headers
        self.category = HTTPErrorCategory.from(statusCode: statusCode)
    }
    
    public enum HTTPErrorCategory {
        case informational  // 1xx
        case success        // 2xx
        case redirection    // 3xx
        case clientError    // 4xx
        case serverError    // 5xx
        case unknown        // Other
        
        static func from(statusCode: Int) -> HTTPErrorCategory {
            switch statusCode {
            case 100...199: return .informational
            case 200...299: return .success
            case 300...399: return .redirection
            case 400...499: return .clientError
            case 500...599: return .serverError
            default: return .unknown
            }
        }
    }
}
