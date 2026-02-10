import Foundation

/// Main SSE (Server-Sent Events) implementation that manages connection lifecycle and event
/// delivery using `URLSession.bytes()` for streaming. Follows the same architectural patterns
/// as the WebSocket implementation: actor-based thread safety, `AsyncStream` for events and
/// state, and structured concurrency.
public actor ServerSentEventManager: ServerSentEventClient {
    private let session: NetworkSession
    private let sseRequest: SSERequest

    /// Connection state; state changes are automatically propagated to `stateEvents` consumers via the didSet observer.
    private var connectionState: SSEConnectionState = .notConnected {
        didSet {
            stateEventContinuation.yield(connectionState)
        }
    }

    private let eventsStream: AsyncStream<ServerSentEvent>
    private let eventsContinuation: AsyncStream<ServerSentEvent>.Continuation

    private let stateEventStream: AsyncStream<SSEConnectionState>
    private let stateEventContinuation: AsyncStream<SSEConnectionState>.Continuation

    /// Tracks the background task that consumes the byte stream and parses SSE events.
    private var streamingTask: Task<Void, Never>?

    private let parser: SSEParser

    /// Last event ID received; sent as `Last-Event-ID` header on reconnect per SSE spec.
    private var lastEventId: String?

    // MARK: - Init

    /// Convenience initializer using a URL string and optional headers.
    /// - Parameters:
    ///   - url: The SSE endpoint URL.
    ///   - additionalHeaders: Optional HTTP headers to include in the request.
    ///   - session: The network session to use; defaults to a shared `Session()`.
    public init(
        url: String,
        additionalHeaders: [HTTPHeader]? = nil,
        session: NetworkSession = Session()
    ) {
        self.init(
            request: SSERequest(url: url, additionalheaders: additionalHeaders),
            session: session
        )
    }

    /// Primary initializer using an `SSERequest` and optional session.
    /// - Parameters:
    ///   - request: The SSE request configuration.
    ///   - session: The network session to use; defaults to a shared `Session()`.
    public init(
        request: SSERequest,
        session: NetworkSession = Session()
    ) {
        self.sseRequest = request
        self.session = session
        self.parser = SSEParser()
        let (eventsStream, eventsContinuation) = AsyncStream<ServerSentEvent>.makeStream()
        self.eventsStream = eventsStream
        self.eventsContinuation = eventsContinuation
        let (stateEventStream, stateEventContinuation) = AsyncStream<SSEConnectionState>.makeStream()
        self.stateEventStream = stateEventStream
        self.stateEventContinuation = stateEventContinuation
    }
}
