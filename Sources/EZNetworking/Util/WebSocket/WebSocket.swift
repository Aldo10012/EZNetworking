import Foundation

public actor WebSocket: WebSocketClient {
    
    public init() {
        
    }
    
    public nonisolated var stateChanges: AsyncStream<WebSocketConnectionState> {
        // TODO: implement
        AsyncStream<WebSocketConnectionState> { $0.finish() }
    }
    
    public func connect() async throws {
        // TODO: implement
    }
    
    public func disconnect(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async {
        // TODO: implement
    }
    
    public func send(_ message: OutboundMessage) async throws {
        // TODO: implement
    }
    
    public nonisolated func messages() -> AsyncThrowingStream<InboundMessage, any Error> {
        // TODO: implement
        AsyncThrowingStream<InboundMessage, Error> { $0.finish() }
    }
}
