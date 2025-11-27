import Foundation

public typealias OutboundMessage = URLSessionWebSocketTask.Message

public protocol WebSocketClient {
    func connect(with url: URL,
                 protocols: [String],
                 pingPongIntervalSeconds: UInt64,
                 pingPongMaximumConsecutiveFailures: Int) async throws

    func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async
    
    func send(_ message: OutboundMessage) async throws

    var connectionStateStream: AsyncStream<WebSocketConnectionState> { get }
}
