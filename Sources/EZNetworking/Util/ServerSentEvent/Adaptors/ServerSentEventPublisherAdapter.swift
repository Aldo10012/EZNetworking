import Combine
import Foundation

public final class ServerSentEventPublisherAdapter: ServerSentEventPublisherClient {
    public func connect() -> AnyPublisher<Void, any Error> {
        // TODO: add
    }
    
    public func disconnect() -> AnyPublisher<Void, any Error> {
        // TODO: add
    }
    
    public func terminate() {
        // TODO: add
    }
    
    public var events: AnyPublisher<ServerSentEvent, Never>
    
    public var stateEvents: AnyPublisher<SSEConnectionState, Never>
}
