import Foundation

public protocol WebSocketClient {
    func connect(with url: URL,
                 protocols: [String],
                 pingPongIntervalSeconds: UInt64,
                 pingPongMaximumConsecutiveFailures: Int) async throws

    func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async

    var connectionStateStream: AsyncStream<WebSocketConnectionState> { get }
}
