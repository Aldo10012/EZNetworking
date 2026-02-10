import Foundation

public actor ServerSentEventManager: ServerSentEventClient {

    // MARK: Properties

    // Dependencies 
    private let session: NetworkSession
    private let sseRequest: SSERequest

    // State
    private var connectionState: SSEConnectionState = .notConnected {
        didSet {
            stateEventContinuation.yield(connectionState)
        }
    }

    // Streams
    private let eventsStream: AsyncStream<ServerSentEvent>
    private let eventsContinuation: AsyncStream<ServerSentEvent>.Continuation

    private let stateEventStream: AsyncStream<SSEConnectionState>
    private let stateEventContinuation: AsyncStream<SSEConnectionState>.Continuation

    // MARK: init 

    public init(
        request: SSERequest,
        session: NetworkSession = Session()
    ) {
        self.sseRequest = request
        self.session = session

        let (eventsStream, eventsContinuation) = AsyncStream<ServerSentEvent>.makeStream()
        self.eventsStream = eventsStream
        self.eventsContinuation = eventsContinuation

        let (stateEventStream, stateEventContinuation) = AsyncStream<SSEConnectionState>.makeStream()
        self.stateEventStream = stateEventStream
        self.stateEventContinuation = stateEventContinuation
    }

    // MARK: Deinit

    deinit {
        eventsContinuation.finish()
        stateEventContinuation.finish()
    }

    // MARK: Pubic API

    public func connect() async throws {
        if case .connecting = connectionState {
            throw SSEError.stillConnecting
        }
        if case .connected = connectionState {
            throw SSEError.alreadyConnected
        }
        connectionState = .connecting

        // TODO: implement connection logic
    }

    public func disconnect() async throws {
        // TODO: implement
    }

    public func terminate() async {
        // TODO: implement
    }

    public var events: AsyncStream<ServerSentEvent> {
        eventsStream
    }

    public var stateEvents: AsyncStream<SSEConnectionState> {
        stateEventStream
    }

    // MARK: Helpers

}
