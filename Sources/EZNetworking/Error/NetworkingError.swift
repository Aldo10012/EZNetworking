import Foundation

public enum NetworkingError: Error {
    // MARK: - Internal errors
    case internalError(InternalError)

    // MARK: - HTTP Status Code errors
    case httpRedirectError(HTTPNetworkingRedirectionError)
    case httpClientError(HTTPNetworkingClientError)
    case httpServerError(HTTPNetworkingServerError)

    // MARK: - URL Errors
    case urlError(URLError)
}

extension NetworkingError: Equatable {
    public static func ==(lhs: NetworkingError, rhs: NetworkingError) -> Bool {
        switch (lhs, rhs) {
        case let (.internalError(error1), .internalError(error2)):
            return error1 == error2
            
        case let (.httpRedirectError(error1), .httpRedirectError(error2)):
            return error1 == error2
        
        case let (.httpClientError(error1), .httpClientError(error2)):
            return error1 == error2
        
        case let (.httpServerError(error1), .httpServerError(error2)):
            return error1 == error2

        case let (.urlError(error), .urlError(error2)):
            return error == error2

        default:
            return false
        }
    }
}
