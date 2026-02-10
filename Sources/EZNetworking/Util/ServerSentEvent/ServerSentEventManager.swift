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

    // MARK: - Connect

    /// Initiates the SSE connection: validates state, builds the request, starts the byte stream, and runs the streaming loop in a background task.
    public func connect() async throws {
        if case .connecting = connectionState {
            throw SSEError.stillConnecting
        }
        if case .connected = connectionState {
            throw SSEError.alreadyConnected
        }
        connectionState = .connecting

        let urlRequest: URLRequest
        do {
            var baseRequest = try sseRequest.getURLRequest()
            if let lastEventId {
                baseRequest.setValue(lastEventId, forHTTPHeaderField: "Last-Event-ID")
            }
            urlRequest = baseRequest
        } catch {
            connectionState = .disconnected(.streamError(error))
            throw error
        }

        let bytes: URLSession.AsyncBytes
        let httpResponse: HTTPURLResponse
        do {
            let (stream, response) = try await session.urlSession.bytes(for: urlRequest)
            bytes = stream
            guard let response = response as? HTTPURLResponse else {
                throw SSEError.invalidResponse
            }
            httpResponse = response
        } catch {
            connectionState = .disconnected(.streamError(error))
            throw error
        }

        // Validate HTTP status and Content-Type per SSE spec.
        guard httpResponse.statusCode == 200 else {
            connectionState = .disconnected(.streamError(SSEError.invalidStatusCode(httpResponse.statusCode)))
            throw SSEError.invalidStatusCode(httpResponse.statusCode)
        }
        let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type")
        guard let contentType, contentType.lowercased().contains("text/event-stream") else {
            connectionState = .disconnected(.streamError(SSEError.invalidContentType(contentType)))
            throw SSEError.invalidContentType(contentType)
        }
        connectionState = .connected
        // State change automatically yielded via connectionState didSet.

        // Streaming continues in a background task; connect() returns once the loop is started.
        startStreamingLoop(bytes: bytes)
    }

    // MARK: - deinit

    /// Cleans up streams and the streaming task on deallocation so consumers are finished and the background task stops.
    deinit {
        eventsContinuation.finish()
        stateEventContinuation.finish()
        streamingTask?.cancel()
    }
}
