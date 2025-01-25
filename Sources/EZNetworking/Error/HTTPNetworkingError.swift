import Foundation

public enum HTTPNetworkingStatusCodeErrorType: Equatable {
    // Successful Responses (200-299)
    case ok

    // Redirection Messages (300-399)
    case redirectionMessageError(HTTPNetworkingRedirectionError)

    // Client Errors (400-499)
    case clientSideError(HTTPNetworkingClientError)

    // Server Errors (500-599)
    case serverSideError(HTTPNetworkingServerError)

    case unknown
    
    public static func evaluate(from statusCode: Int) -> HTTPNetworkingStatusCodeErrorType {
        return switch statusCode {
        case 200...299: .ok
        case 300...399: .redirectionMessageError(HTTPNetworkingRedirectionError(statusCode: statusCode))
        case 400...499: .clientSideError(HTTPNetworkingClientError(statusCode: statusCode))
        case 500...599: .serverSideError(HTTPNetworkingServerError(statusCode: statusCode))
        default: .unknown
        }
    }
}
