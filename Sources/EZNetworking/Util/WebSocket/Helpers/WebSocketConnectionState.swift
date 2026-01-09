import Foundation

public enum WebSocketConnectionState: Equatable {
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
            return true
        case (.connecting, .connecting):
            return true
        case (.connected(let lhsProto), .connected(let rhsProto)):
            return lhsProto == rhsProto
        case (.disconnected(let lhsError), .disconnected(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
    
    public enum DisconnectReason: Equatable {
        /// socket was manually disconnected by user
        case manuallyDisconnected
        /// socket failed to establish connection
        case failedToConnect(error: WebSocketError)
        /// socket abruptly lost connection (server connection lost)
        case connectionLost(error: WebSocketError)
        /// socket was terminated
        case terminated
        
        public static func == (lhs: DisconnectReason, rhs: DisconnectReason) -> Bool {
            switch (lhs, rhs) {
            case (.manuallyDisconnected, .manuallyDisconnected), (.terminated, .terminated):
                return true
            case (.failedToConnect(let lhsError), .failedToConnect(let rhsError)):
                return lhsError == rhsError
            case (.connectionLost(let lhsError), .connectionLost(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
}
