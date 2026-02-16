import Foundation

public protocol ServerSentEventCallbackClient {
    func connect(completion: @escaping (Result<Void, Error>) -> Void)
    func disconnect(completion: @escaping (Result<Void, Error>) -> Void)
    func terminate()
    func onEvent(_ handler: @escaping (ServerSentEvent) -> Void)
    func onStateChange(_ handler: @escaping (SSEConnectionState) -> Void)
}
