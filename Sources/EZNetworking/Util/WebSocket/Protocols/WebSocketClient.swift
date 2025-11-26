import Foundation

public protocol WebSocketClient {
    func connect(with url: URL,
                 protocols: [String],
                 pingPongIntervalSeconds: UInt64,
                 pingPongMaximumConsecutiveFailures: Int) async throws
}
