import Foundation

public enum WebSocketConnectionState: Equatable {
    case idle
    case disconnected
    case connecting
    case connected(protocol: String?)
    case connectionLost(reason: WebSocketError)
    case failed(error: WebSocketError)

    public static func == (lhs: WebSocketConnectionState, rhs: WebSocketConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.disconnected, .disconnected):
            return true
        case (.connecting, .connecting):
            return true
        case (.connected(let lhsProto), .connected(let rhsProto)):
            return lhsProto == rhsProto
        case (.connectionLost(let lhsError), .connectionLost(let rhsError)):
            return lhsError == rhsError
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}
