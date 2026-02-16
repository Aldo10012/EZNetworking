import Foundation

public enum WebSocketError: Error, @unchecked Sendable {
    // URL error
    case invalidWebSocketURLRequest

    // Connection errors
    case notConnected
    case stillConnecting
    case alreadyConnected
    case connectionFailed(underlying: Error)

    // Communication errors
    case sendFailed(underlying: Error)
    case receiveFailed(underlying: Error)

    // Ping/pong errors
    case pingFailed(underlying: Error)
    case pongTimeout

    // Disconnection errors
    case unexpectedDisconnection(code: URLSessionWebSocketTask.CloseCode, reason: String?)
    case forcedDisconnection
}

// MARK: - LocalizedError conformance for better error messages

extension WebSocketError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidWebSocketURLRequest:
            return "WebSocket URLRequest is invalid"
        case .notConnected:
            return "WebSocket is not connected"
        case .stillConnecting:
            return "WebSocket is still connecting"
        case .alreadyConnected:
            return "WebSocket is already connected"
        case let .connectionFailed(error):
            return "WebSocket connection failed: \(error.localizedDescription)"
        case let .sendFailed(error):
            return "Failed to send WebSocket message: \(error.localizedDescription)"
        case let .receiveFailed(error):
            return "Failed to receive WebSocket message: \(error.localizedDescription)"
        case let .pingFailed(error):
            return "WebSocket ping failed: \(error.localizedDescription)"
        case .pongTimeout:
            return "WebSocket pong response timed out"
        case let .unexpectedDisconnection(code, reason):
            let reasonText = reason ?? "No reason provided"
            return "WebSocket disconnected unexpectedly with code \(code.rawValue): \(reasonText)"
        case .forcedDisconnection:
            return "WebSocket was forcefully disconnected"
        }
    }
}

// MARK: - CustomStringConvertible for debugging

extension WebSocketError: CustomStringConvertible {
    public var description: String {
        errorDescription ?? "Unknown WebSocket error"
    }
}

// MARK: - Equatable (useful for testing)

extension WebSocketError: Equatable {
    public static func == (lhs: WebSocketError, rhs: WebSocketError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidWebSocketURLRequest, .invalidWebSocketURLRequest),
             (.notConnected, .notConnected),
             (.stillConnecting, .stillConnecting),
             (.alreadyConnected, .alreadyConnected),
             (.pongTimeout, .pongTimeout),
             (.forcedDisconnection, .forcedDisconnection):
            true

        case let (
            .unexpectedDisconnection(lhsCode, lhsReason),
            .unexpectedDisconnection(rhsCode, rhsReason)
        ):
            lhsCode == rhsCode && lhsReason == rhsReason

        // For errors with underlying errors, compare type names
        case let (.connectionFailed(lhsError), .connectionFailed(rhsError)),
             let (.sendFailed(lhsError), .sendFailed(rhsError)),
             let (.receiveFailed(lhsError), .receiveFailed(rhsError)),
             let (.pingFailed(lhsError), .pingFailed(rhsError)):
            (lhsError as NSError) == (rhsError as NSError)

        default:
            false
        }
    }
}
