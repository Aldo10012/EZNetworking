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
        case .connectionFailed(let error):
            return "WebSocket connection failed: \(error.localizedDescription)"
            
        case .sendFailed(let error):
            return "Failed to send WebSocket message: \(error.localizedDescription)"
        case .receiveFailed(let error):
            return "Failed to receive WebSocket message: \(error.localizedDescription)"
        case .pingFailed(let error):
            return "WebSocket ping failed: \(error.localizedDescription)"
        case .pongTimeout:
            return "WebSocket pong response timed out"
            
        case .unexpectedDisconnection(let code, let reason):
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
            return true
            
        case (.unexpectedDisconnection(let lhsCode, let lhsReason),
              .unexpectedDisconnection(let rhsCode, let rhsReason)):
            return lhsCode == rhsCode && lhsReason == rhsReason
            
        // For errors with underlying errors, compare type names
        case (.connectionFailed(let lhsError), .connectionFailed(let rhsError)),
             (.sendFailed(let lhsError), .sendFailed(let rhsError)),
             (.receiveFailed(let lhsError), .receiveFailed(let rhsError)),
             (.pingFailed(let lhsError), .pingFailed(let rhsError)):
            return (lhsError as NSError) == (rhsError as NSError)

        default:
            return false
        }
    }
}
