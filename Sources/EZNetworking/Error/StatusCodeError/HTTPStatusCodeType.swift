import Foundation

public enum HTTPStatusCodeType: Equatable {
    // Successful Responses (200-299)
    case ok

    // Redirection Messages (300-399)
    case redirectionMessage(HTTPRedirectionStatus)

    // Client Errors (400-499)
    case clientSideError(HTTPClientStatus)

    // Server Errors (500-599)
    case serverSideError(HTTPServerStatus)

    case unknown
    
    public static func evaluate(from statusCode: Int) -> HTTPStatusCodeType {
        return switch statusCode {
        case 200...299: .ok
        case 300...399: .redirectionMessage(HTTPRedirectionStatus(statusCode: statusCode))
        case 400...499: .clientSideError(HTTPClientStatus(statusCode: statusCode))
        case 500...599: .serverSideError(HTTPServerStatus(statusCode: statusCode))
        default: .unknown
        }
    }
}
