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
