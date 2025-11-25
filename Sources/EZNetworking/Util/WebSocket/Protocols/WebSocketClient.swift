import Foundation

public typealias OutboundMessage = URLSessionWebSocketTask.Message
public typealias InboundMessage = URLSessionWebSocketTask.Message

public protocol WebSocketClient {
    // MARK: - Connection Management
    
    /// Connect to the WebSocket server
    func connect(with url: URL) async throws
    
    /// Connect to the WebSocket server with specific sub-protocols
    func connect(with url: URL, protocols: [String]) async throws
    
    /// Disconnect from the WebSocket server
    func disconnect() async
    
    /// Disconnect with specific close code and reason
    func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async
    
    // MARK: - Messaging
    
    /// Send a message to the WebSocket
    func send(_ message: OutboundMessage) async throws
    
    /// Stream of incoming messages
    func messages() throws -> AsyncStream<InboundMessage>
    
    // MARK: - State Observation
    
    /// Stream of connection state changes
    var connectionStateStream: AsyncStream<WebSocketConnectionState> { get async }
}
