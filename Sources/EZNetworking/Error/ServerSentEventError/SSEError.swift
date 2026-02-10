import Foundation

public enum SSEError: Error, Sendable {
    // Connection state errors
    case notConnected
    case stillConnecting
    case alreadyConnected
    case connectionFailed(underlying: Error)

    // Response validation errors
    case invalidResponse
    case invalidHTTPResponse(HTTPResponse)

    // Disconnection errors
    case unexpectedDisconnection
}

// MARK: LocalizedError

extension SSEError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notConnected:
            return "The SSE connection is not currently established."
        case .stillConnecting:
            return "A connection attempt is already in progress."
        case .alreadyConnected:
            return "The SSE connection is already established."
        case let .connectionFailed(underlying):
            return "Failed to establish SSE connection: \(underlying.localizedDescription)"
        case .invalidResponse:
            return "The server response was not a valid HTTP response."
        case let .invalidHTTPResponse(httpResponse):
            if httpResponse.category != .success {
                return "The server returned HTTP status \(httpResponse.statusCode). Expected 2xx status code for SSE connection."
            } else {
                // Must be Content-Type issue
                let contentType = httpResponse.headers["Content-Type"] ?? httpResponse.headers["content-type"] ?? "not specified"
                return "The server returned an invalid Content-Type: '\(contentType)'. Expected 'text/event-stream'."
            }
        case .unexpectedDisconnection:
            return "The SSE connection was unexpectedly closed."
        }
    }
}

// MARK: Equatable

extension SSEError: Equatable {
    public static func == (lhs: SSEError, rhs: SSEError) -> Bool {
        switch (lhs, rhs) {
        case (.notConnected, .notConnected),
             (.stillConnecting, .stillConnecting),
             (.alreadyConnected, .alreadyConnected),
             (.invalidResponse, .invalidResponse),
             (.unexpectedDisconnection, .unexpectedDisconnection):
            true

        case let (.connectionFailed(errorA), .connectionFailed(errorB)):
            (errorA as NSError) == (errorB as NSError)

        case let (.invalidHTTPResponse(httpResponseA), .invalidHTTPResponse(httpResponseB)):
            httpResponseA.statusCode == httpResponseB.statusCode

        default:
            false
        }
    }
}
