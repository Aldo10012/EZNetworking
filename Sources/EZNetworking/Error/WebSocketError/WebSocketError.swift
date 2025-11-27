import Foundation

public enum WebSocketError: Error {
    // Connection errors
    case notConnected
    case stillConnecting
    case alreadyConnected
    case connectionFailed(underlying: Error)
    case connectionTimeout
    case invalidURL
    case unsupportedProtocol(String)
    
    // Communication errors
    case sendFailed(underlying: Error)
    case receiveFailed(underlying: Error)
    case invalidMessageFormat
    case messageEncodingFailed
    case messageDecodingFailed
    
    // Ping/pong errors
    case pingFailed(underlying: Error)
    case pongTimeout
    case keepAliveFailure(consecutiveFailures: Int)
    
    // Disconnection errors
    case unexpectedDisconnection(code: URLSessionWebSocketTask.CloseCode, reason: String?)
    case forcedDisconnection
    
    // Task errors
    case taskNotInitialized
    case taskCancelled
    
    // Stream errors
    case streamAlreadyCreated
    case streamNotAvailable
}

// MARK: - LocalizedError conformance for better error messages

extension WebSocketError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notConnected:
            return "WebSocket is not connected"
        case .stillConnecting:
            return "WebSocket is still connecting"
        case .alreadyConnected:
            return "WebSocket is already connected"
        case .connectionFailed(let error):
            return "WebSocket connection failed: \(error.localizedDescription)"
        case .connectionTimeout:
            return "WebSocket connection timed out"
        case .invalidURL:
            return "Invalid WebSocket URL"
        case .unsupportedProtocol(let protocolString):
            return "Unsupported WebSocket protocol: \(protocolString)"
            
        case .sendFailed(let error):
            return "Failed to send WebSocket message: \(error.localizedDescription)"
        case .receiveFailed(let error):
            return "Failed to receive WebSocket message: \(error.localizedDescription)"
        case .invalidMessageFormat:
            return "Invalid WebSocket message format"
        case .messageEncodingFailed:
            return "Failed to encode message for WebSocket"
        case .messageDecodingFailed:
            return "Failed to decode WebSocket message"
            
        case .pingFailed(let error):
            return "WebSocket ping failed: \(error.localizedDescription)"
        case .pongTimeout:
            return "WebSocket pong response timed out"
        case .keepAliveFailure(let count):
            return "WebSocket keep-alive failed after \(count) consecutive attempts"
            
        case .unexpectedDisconnection(let code, let reason):
            let reasonText = reason ?? "No reason provided"
            return "WebSocket disconnected unexpectedly with code \(code.rawValue): \(reasonText)"
        case .forcedDisconnection:
            return "WebSocket was forcefully disconnected"
            
        case .taskNotInitialized:
            return "WebSocket task is not initialized"
        case .taskCancelled:
            return "WebSocket task was cancelled"
            
        case .streamAlreadyCreated:
            return "WebSocket message stream has already been created"
        case .streamNotAvailable:
            return "WebSocket message stream is not available"
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
        case (.notConnected, .notConnected),
             (.stillConnecting, .stillConnecting),
             (.alreadyConnected, .alreadyConnected),
             (.connectionTimeout, .connectionTimeout),
             (.invalidURL, .invalidURL),
             (.invalidMessageFormat, .invalidMessageFormat),
             (.messageEncodingFailed, .messageEncodingFailed),
             (.messageDecodingFailed, .messageDecodingFailed),
             (.pongTimeout, .pongTimeout),
             (.forcedDisconnection, .forcedDisconnection),
             (.taskNotInitialized, .taskNotInitialized),
             (.taskCancelled, .taskCancelled),
             (.streamAlreadyCreated, .streamAlreadyCreated),
             (.streamNotAvailable, .streamNotAvailable):
            return true
            
        case (.unsupportedProtocol(let lhsProto), .unsupportedProtocol(let rhsProto)):
            return lhsProto == rhsProto
            
        case (.keepAliveFailure(let lhsCount), .keepAliveFailure(let rhsCount)):
            return lhsCount == rhsCount
            
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
