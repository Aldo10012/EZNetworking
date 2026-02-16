import Foundation

public final class WebSocketCallbackClientAdapter: WebSocketCallbackClient {
    private let actor: any WebSocketClient
    private var messageHandler: ((InboundMessage) -> Void)?
    private var stateHandler: ((WebSocketConnectionState) -> Void)?
    private var messageTask: Task<Void, Never>?
    private var stateTask: Task<Void, Never>?

    public init(actor: any WebSocketClient) {
        self.actor = actor
    }

    public func connect(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await actor.connect()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func disconnect(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await actor.disconnect()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func terminate() {
        Task { await actor.terminate() }
    }

    public func send(_ message: OutboundMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await actor.send(message)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func onMessage(_ handler: @escaping (InboundMessage) -> Void) {
        messageHandler = handler
        messageTask?.cancel()
        messageTask = Task {
            for await msg in await actor.messages {
                handler(msg)
            }
        }
    }

    public func onStateChange(_ handler: @escaping (WebSocketConnectionState) -> Void) {
        stateHandler = handler
        stateTask?.cancel()
        stateTask = Task {
            for await state in await actor.stateEvents {
                handler(state)
            }
        }
    }
}
