import Combine
import Foundation

public protocol ServerSentEventPublisherClient {
    func connect() -> AnyPublisher<Void, Error>
    func disconnect() -> AnyPublisher<Void, Error>
    func terminate()
    var events: AnyPublisher<ServerSentEvent, Never> { get }
    var stateEvents: AnyPublisher<SSEConnectionState, Never> { get }
}
