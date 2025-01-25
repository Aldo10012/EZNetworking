import Foundation

public enum HTTPNetworkingError: Error, Equatable {
    // Successful Responses (200-299)
    case ok

    // Redirection Messages (300-399)
    case redirectionMessageError(HTTPNetworkingRedirectionError)

    // Client Errors (400-499)
    case clientSideError(HTTPNetworkingClientError)

    // Server Errors (500-599)
    case serverSideError(HTTPNetworkingServerError)

    case unknown
}

public enum HTTPNetworkingServerError: Error {
    case internalServerError
    case notImplemented
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case httpVersionNotSupported
    case variantAlsoNegotiates
    case insufficientStorage
    case loopDetected
    case notExtended
    case networkAuthenticationRequired
    case unknown
    
    static func fromStatusCode(_ statusCode: Int) -> HTTPNetworkingServerError {
        return switch statusCode {
        case 500: .internalServerError
        case 501: .notImplemented
        case 502: .badGateway
        case 503: .serviceUnavailable
        case 504: .gatewayTimeout
        case 505: .httpVersionNotSupported
        case 506: .variantAlsoNegotiates
        case 507: .insufficientStorage
        case 508: .loopDetected
        case 510: .notExtended
        case 511: .networkAuthenticationRequired
        default: .unknown
        }
    }
}
