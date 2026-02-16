import Foundation

public enum SSEError: Error, Sendable {
    // Connection state errors
    case notConnected
    case stillConnecting
    case alreadyConnected
    case connectionFailed(underlying: Error)
    case maxReconnectAttemptsReached

    // Response validation errors
    case invalidResponse
    case invalidHTTPResponse(HTTPResponse)

    // Disconnection errors
    case unexpectedDisconnection
}

// MARK: Equatable

extension SSEError: Equatable {
    public static func == (lhs: SSEError, rhs: SSEError) -> Bool {
        switch (lhs, rhs) {
        case (.notConnected, .notConnected),
             (.stillConnecting, .stillConnecting),
             (.alreadyConnected, .alreadyConnected),
             (.invalidResponse, .invalidResponse),
             (.unexpectedDisconnection, .unexpectedDisconnection),
             (.maxReconnectAttemptsReached, .maxReconnectAttemptsReached):
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
