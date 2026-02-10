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
            "The SSE connection is not currently established."

        case .stillConnecting:
            "A connection attempt is already in progress."

        case .alreadyConnected:
            "The SSE connection is already established."

        case let .connectionFailed(underlying):
            "Failed to establish SSE connection: \(underlying.localizedDescription)"

        case .invalidResponse:
            "The server response was not a valid HTTP response."

        case let .invalidStatusCode(statusCode):
            "The server returned an invalid status code: \(statusCode). Expected 200 OK."

        case let .invalidContentType(contentType):
            if let contentType {
                "The server returned an invalid Content-Type: '\(contentType)'. Expected 'text/event-stream'."
            } else {
                "The server did not specify a Content-Type header. Expected 'text/event-stream'."
            }

        case .unexpectedDisconnection:
            "The SSE connection was unexpectedly closed."
        }
    }
}
