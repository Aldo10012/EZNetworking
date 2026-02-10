import Foundation

public enum SSEError: Error, LocalizedError, Sendable {

    // Connection state errors
    case notConnected
    case stillConnecting
    case alreadyConnected
    case connectionFailed(underlying: Error)

    // Response validation errors
    case invalidResponse
    case invalidStatusCode(Int)
    case invalidContentType(String?)

    // Disconnection errors
    case unexpectedDisconnection

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case .notConnected:
            return "The SSE connection is not currently established."

        case .stillConnecting:
            return "A connection attempt is already in progress."

        case .alreadyConnected:
            return "The SSE connection is already established."

        case .connectionFailed(let underlying):
            return "Failed to establish SSE connection: \(underlying.localizedDescription)"

        case .invalidResponse:
            return "The server response was not a valid HTTP response."

        case .invalidStatusCode(let statusCode):
            return "The server returned an invalid status code: \(statusCode). Expected 200 OK."

        case .invalidContentType(let contentType):
            if let contentType {
                return "The server returned an invalid Content-Type: '\(contentType)'. Expected 'text/event-stream'."
            } else {
                return "The server did not specify a Content-Type header. Expected 'text/event-stream'."
            }

        case .unexpectedDisconnection:
            return "The SSE connection was unexpectedly closed."
        }
    }
}
