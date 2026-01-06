import Foundation

public typealias OutboundMessage = URLSessionWebSocketTask.Message
public typealias InboundMessage = URLSessionWebSocketTask.Message

/// A client for managing WebSocket connections.
public protocol WebSocketClient: Sendable {

    /// Establishes a connection to the WebSocket server.
    func connect() async throws

    /// Disconnects from the WebSocket server.
    func disconnect() async throws

    /// Sends a message to the WebSocket server.
    func send(_ message: OutboundMessage) async throws

    /// Returns a stream of messages received from the WebSocket server.
    var messages: AsyncThrowingStream<InboundMessage, Error> { get }

    /// A stream of connection state changes.
    var stateEvents: AsyncStream<WebSocketConnectionState> { get }
}
