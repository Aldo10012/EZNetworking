import Foundation

public enum HTTPStatusCodeType: Equatable {
    case success(HTTPSuccessStatus)                  // 2xx success
    case redirectionMessage(HTTPRedirectionStatus)   // 3xx redirect message
    case clientSideError(HTTPClientErrorStatus)      // 4xx client errors
    case serverSideError(HTTPServerStatus)           // 5xx server errors
    case unknown
    
    public static func evaluate(from statusCode: Int) -> HTTPStatusCodeType {
        return switch statusCode {
        case 200...299: .success(HTTPSuccessStatus(statusCode: statusCode))
        case 300...399: .redirectionMessage(HTTPRedirectionStatus(statusCode: statusCode))
        case 400...499: .clientSideError(HTTPClientErrorStatus(statusCode: statusCode))
        case 500...599: .serverSideError(HTTPServerStatus(statusCode: statusCode))
        default: .unknown
        }
    }
}

public extension HTTPStatusCodeType {
    enum AcceptableStatus {
        case success(HTTPSuccessStatus)
        case redirectionMessage(HTTPRedirectionStatus)
    }
}
