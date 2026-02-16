import Combine
import Foundation

public protocol WebSocketPublisherClient {
    func connect() -> AnyPublisher<Void, Error>
    func disconnect() -> AnyPublisher<Void, Error>
    func terminate()
    func send(_ message: OutboundMessage) -> AnyPublisher<Void, Error>
    var messages: AnyPublisher<InboundMessage, Never> { get }
    var stateEvents: AnyPublisher<WebSocketConnectionState, Never> { get }
}
