import Foundation

public typealias OutboundMessage = URLSessionWebSocketTask.Message
public typealias InboundMessage = URLSessionWebSocketTask.Message

/// A client for managing WebSocket connections.
public protocol WebSocketClient: Actor {

    /// Establishes a connection to the WebSocket server.
    func connect() async throws

    /// Disconnects from the WebSocket server, but does not fully shut down streams, allowing reuse of streams on reconnect.
    func disconnect() async throws

    /// Fully shuts down the WebSocket connection, ending all streams and releasing all resources. Use when you are done using the WebSocket.
    func terminate() async

    /// Sends a message to the WebSocket server.
    func send(_ message: OutboundMessage) async throws

    /// Returns a stream of messages received from the WebSocket server.
    var messages: AsyncStream<InboundMessage> { get }

    /// A stream of connection state changes.
    var stateEvents: AsyncStream<WebSocketConnectionState> { get }
}
