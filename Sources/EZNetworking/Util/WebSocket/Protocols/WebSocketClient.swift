import Foundation

public protocol WebSocketClient {
    func connect(with url: URL, protocols: [String]) async throws
}
