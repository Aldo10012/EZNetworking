import Foundation

public enum WebSocketFailureReason: Equatable, Sendable {
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

extension WebSocketFailureReason {
    public static func == (lhs: WebSocketFailureReason, rhs: WebSocketFailureReason) -> Bool {
        switch (lhs, rhs) {
        case (.notConnected, .notConnected),
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
