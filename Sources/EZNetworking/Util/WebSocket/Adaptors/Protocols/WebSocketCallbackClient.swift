import Foundation

public protocol WebSocketCallbackClient {
    func connect(completion: @escaping (Result<Void, Error>) -> Void)
    func disconnect(completion: @escaping (Result<Void, Error>) -> Void)
    func terminate()
    func send(_ message: OutboundMessage, completion: @escaping (Result<Void, Error>) -> Void)
    func onMessage(_ handler: @escaping (InboundMessage) -> Void)
    func onStateChange(_ handler: @escaping (WebSocketConnectionState) -> Void)
}
