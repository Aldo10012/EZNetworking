import Foundation

extension HTTPNetworkingError {
    static func fromStatusCode(_ statusCode: Int) -> HTTPNetworkingError? {
        return switch statusCode {

        // Successful Responses (200-299)
        case 200...299: nil

        // Redirection Messages (300-399)
        case 300...399: HTTPNetworkingError.redirectionMessageError(HTTPNetworkingRedirectionError.fromStatusCode(statusCode))

        // Client Errors (400-499)
        case 400...499: HTTPNetworkingError.clientSideError(HTTPNetworkingClientError.fromStatusCode(statusCode))

        // Server Errors (500-599)
        case 500...599: HTTPNetworkingError.serverSideError(HTTPNetworkingServerError.fromStatusCode(statusCode))

        // Unknown or Unhandled Status Code
        default: .unknown
        }
    }
}
