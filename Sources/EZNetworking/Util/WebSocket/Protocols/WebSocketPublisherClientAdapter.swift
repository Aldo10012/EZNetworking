import Foundation
import Combine

public final class WebSocketPublisherClientAdapter: WebSocketPublisherClient {
    private let actor: any WebSocketClient
    private var messageSubject = PassthroughSubject<InboundMessage, Never>()
    private var stateSubject = PassthroughSubject<WebSocketConnectionState, Never>()
    private var messageTask: Task<Void, Never>?
    private var stateTask: Task<Void, Never>?

    public init(actor: any WebSocketClient) {
        self.actor = actor
        subscribeToMessages()
        subscribeToStateEvents()
    }

    public func connect() -> AnyPublisher<Void, Error> {
        Future { [actor] promise in
            Task {
                do {
                    try await actor.connect()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func disconnect() -> AnyPublisher<Void, Error> {
        Future { [actor] promise in
            Task {
                do {
                    try await actor.disconnect()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func terminate() {
        Task { await actor.terminate() }
    }

    public func send(_ message: OutboundMessage) -> AnyPublisher<Void, Error> {
        Future { [actor] promise in
            Task {
                do {
                    try await actor.send(message)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    public var messages: AnyPublisher<InboundMessage, Never> {
        messageSubject.eraseToAnyPublisher()
    }

    public var stateEvents: AnyPublisher<WebSocketConnectionState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    private func subscribeToMessages() {
        messageTask?.cancel()
        messageTask = Task { [weak self] in
            guard let self else { return }
            for await msg in await actor.messages {
                self.messageSubject.send(msg)
            }
        }
    }

    private func subscribeToStateEvents() {
        stateTask?.cancel()
        stateTask = Task { [weak self] in
            guard let self else { return }
            for await state in await actor.stateEvents {
                self.stateSubject.send(state)
            }
        }
    }
}
