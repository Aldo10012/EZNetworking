import Foundation

/// Messages sent to the WebSocket
public typealias OutboundMessage = URLSessionWebSocketTask.Message

/// Messages received from the WebSocket
public typealias InboundMessage = URLSessionWebSocketTask.Message

public protocol WebSocketClient {
    /// Connect to the WebSocket server
    func connect()
    
    /// Disconnect from the WebSocket server
    func disconnect()
    
    /// Send a message (string or binary) to the WebSocket
    func send(_ message: OutboundMessage) async throws
}
