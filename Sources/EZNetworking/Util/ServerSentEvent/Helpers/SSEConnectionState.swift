import Foundation

/// Represents the current connection state of a Server-Sent Event (SSE) stream.
public enum SSEConnectionState: Sendable, Equatable {
    /// The connection has not been started yet.
    case notConnected
    /// The connection is currently being established.
    case connecting
    /// The connection is active and streaming events.
    case connected
    /// The connection has been closed with a specific reason.
    case disconnected(DisconnectReason)

    /// Describes the reason an SSE connection was disconnected.
    public enum DisconnectReason: Sendable, Equatable {
        /// The server closed the stream normally.
        case streamEnded
        /// The stream ended due to an unexpected error.
        case streamError(Error)
        /// The client explicitly disconnected.
        case manuallyDisconnected
        /// The connection was permanently terminated.
        case terminated
    }
}

// MARK: Equatable conformance

extension SSEConnectionState {
    public static func == (lhs: SSEConnectionState, rhs: SSEConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.notConnected, .notConnected),
             (.connecting, .connecting),
             (.connected, .connected):
            true
        case let (.disconnected(reasonA), .disconnected(reasonB)):
            reasonA == reasonB
        default:
            false
        }
    }
}

extension SSEConnectionState.DisconnectReason {
    public static func == (lhs: SSEConnectionState.DisconnectReason, rhs: SSEConnectionState.DisconnectReason) -> Bool {
        switch (lhs, rhs) {
        case (.streamEnded, .streamEnded),
             (.manuallyDisconnected, .manuallyDisconnected),
             (.terminated, .terminated):
            return true
        case let (.streamError(e1), .streamError(e2)):
            let n1 = e1 as NSError
            let n2 = e2 as NSError
            return n1.domain == n2.domain && n1.code == n2.code
        default:
            return false
        }
    }
}
