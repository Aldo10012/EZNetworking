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

    /// Configuration for automatic reconnection behavior.
    private let reconnectionConfig: ReconnectionConfig?

    /// Tracks the current reconnection attempt number for exponential backoff calculation.
    private var reconnectionAttempt: Int = 0

    // MARK: - Init

    /// Convenience initializer using a URL string and optional headers.
    /// - Parameters:
    ///   - url: The SSE endpoint URL.
    ///   - additionalHeaders: Optional HTTP headers to include in the request.
    ///   - reconnectionConfig: Optional reconnection configuration (default: nil, no auto-reconnect).
    ///   - session: The network session to use; defaults to a shared `Session()`.
    public init(
        url: String,
        additionalHeaders: [HTTPHeader]? = nil,
        reconnectionConfig: ReconnectionConfig? = nil,
        session: NetworkSession = Session()
    ) {
        self.init(
            request: SSERequest(url: url, additionalheaders: additionalHeaders),
            reconnectionConfig: reconnectionConfig,
            session: session
        )
    }

    /// Primary initializer using an `SSERequest` and optional session.
    /// - Parameters:
    ///   - request: The SSE request configuration.
    ///   - reconnectionConfig: Optional reconnection configuration (default: nil, no auto-reconnect).
    ///   - session: The network session to use; defaults to a shared `Session()`.
    public init(
        request: SSERequest,
        reconnectionConfig: ReconnectionConfig? = nil,
        session: NetworkSession = Session()
    ) {
        self.sseRequest = request
        self.session = session
        self.reconnectionConfig = reconnectionConfig
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

    // MARK: - Disconnect

    /// Gracefully closes the active SSE connection without finishing the event/state streams, so the client can reconnect later.
    public func disconnect() async throws {
        guard case .connected = connectionState else {
            throw SSEError.notConnected
        }
        cleanup(reason: SSEConnectionState.DisconnectReason.manuallyDisconnected)
    }

    /// Called when the stream ends unexpectedly (e.g. error or server close). Guards against double-disconnect by returning if not currently connected.
    private func handleDisconnection(reason: SSEConnectionState.DisconnectReason) {
        guard case .connected = connectionState else { return }
        cleanup(reason: reason)
    }

    /// Consumes the byte stream line-by-line, parses SSE events, and yields them to `events`; runs in a high-priority background task.
    private func startStreamingLoop(bytes: URLSession.AsyncBytes) {
        streamingTask = Task(priority: .high) {
            do {
                for try await line in bytes.lines {
                    guard !Task.isCancelled else { break }
                    let event = await parser.parseLine(line)
                    if let event {
                        eventsContinuation.yield(event)
                        if let id = event.id {
                            lastEventId = id
                        }
                    }
                }
                // Loop exited normally (stream ended); notify and cleanup.
                handleDisconnection(reason: SSEConnectionState.DisconnectReason.streamEnded)
            } catch {
                // Only treat as error if we weren’t cancelled (e.g. disconnect or terminate).
                guard !Task.isCancelled else { return }
                handleDisconnection(reason: .streamError(error))
            }
        }
    }

    // MARK: - deinit

    /// Cleans up streams and the streaming task on deallocation so consumers are finished and the background task stops.
    deinit {
        eventsContinuation.finish()
        stateEventContinuation.finish()
        streamingTask?.cancel()
    }

    /// Cancels the streaming task and transitions to disconnected state.
    /// Does NOT finish continuations, allowing the client to reconnect later.
    private func cleanup(reason: SSEConnectionState.DisconnectReason) {
        streamingTask?.cancel()
        streamingTask = nil
        connectionState = .disconnected(reason)
        // Note: Do NOT finish continuations here - allows reconnection
    }

    /// Permanently terminates the SSE client: performs final cleanup and finishes all streams.
    /// After calling this, the client instance should not be reused.
    public func terminate() async {
        cleanup(reason: .terminated)
        eventsContinuation.finish()
        stateEventContinuation.finish()
    }

    // MARK: - Public API

    /// Stream of Server-Sent Events received from the server.
    /// The stream remains active across reconnections until `terminate()` is called.
    public var events: AsyncStream<ServerSentEvent> {
        eventsStream
    }

    /// Stream of connection state changes.
    /// Subscribe to monitor the connection lifecycle: notConnected -> connecting -> connected -> disconnected.
    public var stateEvents: AsyncStream<SSEConnectionState> {
        stateEventStream
    }

    /// Attempts to reconnect with exponential backoff based on reconnectionConfig.
    /// Resets attempt counter on successful connection.
    private func attemptReconnection() async {
        guard let config = reconnectionConfig, config.enabled else {
            return
        }
        
        // Check if max attempts reached
        if let maxAttempts = config.maxAttempts, reconnectionAttempt >= maxAttempts {
            return
        }
        
        // Calculate delay with exponential backoff
        let delay = min(
            config.initialDelay * pow(config.backoffMultiplier, Double(reconnectionAttempt)),
            config.maxDelay
        )
        
        // Wait before attempting reconnection
        try? await Task.sleep(for: .seconds(delay))
        
        // Increment attempt counter
        reconnectionAttempt += 1
        
        // Attempt to reconnect
        do {
            try await connect()
            // Success! Reset attempt counter
            reconnectionAttempt = 0
        } catch {
            // Reconnection failed, will retry on next disconnection or manual retry
            // Could log error here if needed
        }
    }
}
