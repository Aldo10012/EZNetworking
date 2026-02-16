import Foundation

public final class ServerSentEventCallbackAdapter: ServerSentEventCallbackClient {
    public func connect(completion: @escaping (Result<Void, any Error>) -> Void) {
        // TODO: add
    }
    
    public func disconnect(completion: @escaping (Result<Void, any Error>) -> Void) {
        // TODO: add
    }
    
    public func terminate() {
        // TODO: add
    }
    
    public func onEvent(_ handler: @escaping (ServerSentEvent) -> Void) {
        // TODO: add
    }
    
    public func onStateChange(_ handler: @escaping (SSEConnectionState) -> Void) {
        // TODO: add
    }
}
