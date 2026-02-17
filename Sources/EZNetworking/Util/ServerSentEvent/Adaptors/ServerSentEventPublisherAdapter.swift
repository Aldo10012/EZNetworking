import Combine
import Foundation

public final class ServerSentEventPublisherAdapter: ServerSentEventPublisherClient {
    private let actor: any ServerSentEventClient
    private var eventSubject = PassthroughSubject<ServerSentEvent, Never>()
    private var stateSubject = PassthroughSubject<SSEConnectionState, Never>()
    private var eventTask: Task<Void, Never>?
    private var stateTask: Task<Void, Never>?

    public convenience init(
        url: String,
        session: NetworkSession = Session(),
        retryPolicy: RetryPolicy? = nil,
        responseValidator: ResponseValidator = DefaultResponseValidator(expectedHttpHeaders: [.contentType(.eventStream)])
    ) {
        let request = SSERequest(url: url)
        self.init(request: request, session: session, retryPolicy: retryPolicy, responseValidator: responseValidator)
    }

    public convenience init(
        request: SSERequest,
        session: NetworkSession = Session(),
        retryPolicy: RetryPolicy? = nil,
        responseValidator: ResponseValidator = DefaultResponseValidator(expectedHttpHeaders: [.contentType(.eventStream)])
    ) {
        self.init(
            serverSentEventClient: ServerSentEventManager(request: request, session: session, retryPolicy: retryPolicy, responseValidator: responseValidator)
        )
    }

    // For testing only
    init(serverSentEventClient: any ServerSentEventClient) {
        actor = serverSentEventClient
        subscribeToEvents()
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

    public var events: AnyPublisher<ServerSentEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    public var stateEvents: AnyPublisher<SSEConnectionState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    private func subscribeToEvents() {
        eventTask?.cancel()
        eventTask = Task { [weak self] in
            guard let self else { return }
            for await event in await actor.events {
                eventSubject.send(event)
            }
        }
    }

    private func subscribeToStateEvents() {
        stateTask?.cancel()
        stateTask = Task { [weak self] in
            guard let self else { return }
            for await state in await actor.stateEvents {
                stateSubject.send(state)
            }
        }
    }
}
