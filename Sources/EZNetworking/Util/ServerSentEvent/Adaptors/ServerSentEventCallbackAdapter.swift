import Foundation

public final class ServerSentEventCallbackAdapter: ServerSentEventCallbackClient {
    private let actor: any ServerSentEventClient
    private var eventHandler: ((ServerSentEvent) -> Void)?
    private var stateHandler: ((SSEConnectionState) -> Void)?
    private var eventTask: Task<Void, Never>?
    private var stateTask: Task<Void, Never>?

    public convenience init(
        url: String,
        session: NetworkSession = Session(),
        retryPolicy: RetryPolicy? = nil,
        responseValidator: ResponseValidator = DefaultResponseValidator(expectedHttpHeaders: [.contentType(.eventStream)])
    ) {
        let request = SSERequest(url: url)
        self.init(
            request: request,
            session: session,
            retryPolicy: retryPolicy,
            responseValidator: responseValidator
        )
    }

    public convenience init(
        request: SSERequest,
        session: NetworkSession = Session(),
        retryPolicy: RetryPolicy? = nil,
        responseValidator: ResponseValidator = DefaultResponseValidator(expectedHttpHeaders: [.contentType(.eventStream)])
    ) {
        self.init(
            serverSentEventClient: ServerSentEventManager(
                request: request,
                session: session,
                retryPolicy: retryPolicy,
                responseValidator: responseValidator
            )
        )
    }

    // For testing only
    init(serverSentEventClient: any ServerSentEventClient) {
        actor = serverSentEventClient
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

    public func onEvent(_ handler: @escaping (ServerSentEvent) -> Void) {
        eventHandler = handler
        eventTask?.cancel()
        eventTask = Task {
            for await event in await actor.events {
                handler(event)
            }
        }
    }

    public func onStateChange(_ handler: @escaping (SSEConnectionState) -> Void) {
        stateHandler = handler
        stateTask?.cancel()
        stateTask = Task {
            for await state in await actor.stateEvents {
                handler(state)
            }
        }
    }
}
