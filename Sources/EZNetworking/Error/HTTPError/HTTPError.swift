import Foundation

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
