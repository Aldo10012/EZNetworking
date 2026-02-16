import Foundation

public enum WebSocketConnectionState: Equatable, Sendable {
    ///  The socket is initialized and ready to connect
    case notConnected
    /// The socket is in the process of connecting
    case connecting
    /// The socket is connected
    case connected(protocol: String?)
    /// The socket is disconnected after being connected
    case disconnected(DisconnectReason)

    public static func == (lhs: WebSocketConnectionState, rhs: WebSocketConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.notConnected, .notConnected):
            true
        case (.connecting, .connecting):
            true
        case let (.connected(lhsProto), .connected(rhsProto)):
            lhsProto == rhsProto
        case let (.disconnected(lhsError), .disconnected(rhsError)):
            lhsError == rhsError
        default:
            false
        }
    }

    public enum DisconnectReason: Equatable, Sendable {
        /// socket was manually disconnected by user
        case manuallyDisconnected
        /// socket failed to establish connection
        case failedToConnect(error: WebSocketFailureReason)
        /// socket abruptly lost connection (server connection lost)
        case connectionLost(error: WebSocketFailureReason)
        /// socket was terminated
        case terminated

        public static func == (lhs: DisconnectReason, rhs: DisconnectReason) -> Bool {
            switch (lhs, rhs) {
            case (.manuallyDisconnected, .manuallyDisconnected), (.terminated, .terminated):
                true
            case let (.failedToConnect(lhsError), .failedToConnect(rhsError)):
                lhsError == rhsError
            case let (.connectionLost(lhsError), .connectionLost(rhsError)):
                lhsError == rhsError
            default:
                false
            }
        }
    }
}
