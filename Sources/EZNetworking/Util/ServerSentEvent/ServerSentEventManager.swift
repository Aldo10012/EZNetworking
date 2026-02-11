import Foundation

public actor ServerSentEventManager: ServerSentEventClient {

    // MARK: Properties

    // Dependencies 
    private let session: NetworkSession
    private var sseRequest: SSERequest
    private let responseValidator: ResponseValidator
    private let parser = SSEParser()

    // State
    private var connectionState: SSEConnectionState = .notConnected {
        didSet {
            stateEventContinuation.yield(connectionState)
        }
    }

    /// Last event ID received; sent as `Last-Event-ID` header on reconnect per SSE spec.
    private var lastEventId: String?

    // Streams
    private let eventsStream: AsyncStream<ServerSentEvent>
    private let eventsContinuation: AsyncStream<ServerSentEvent>.Continuation

    private let stateEventStream: AsyncStream<SSEConnectionState>
    private let stateEventContinuation: AsyncStream<SSEConnectionState>.Continuation

    /// Tracks the background task that consumes the byte stream and parses SSE events.
    private var streamingTask: Task<Void, Never>?

    // MARK: init 

    public init(
        request: SSERequest,
        session: NetworkSession = Session(),
        responseValidator: ResponseValidator = SSEResponseValidator()
    ) {
        self.sseRequest = request
        self.session = session
        self.responseValidator = responseValidator

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
        streamingTask?.cancel()
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

        do {
            sseRequest.setLastEventId(lastEventId)
            let request = try sseRequest.getURLRequest()
            let (bytesStream, response) = try await session.urlSession.bytes(for: request)

            try responseValidator.validateStatus(from: response)
            connectionState = .connected

            startStreamingLoop(bytes: bytesStream)
        } catch let sseError as SSEError {
            connectionState = .disconnected(.streamError(sseError))
            throw sseError
        } catch {
            let sseError = SSEError.connectionFailed(underlying: error)
            connectionState = .disconnected(.streamError(sseError))
            throw sseError
        }
    }

    public func disconnect() async throws {
        guard case .connected = connectionState else {
            throw SSEError.notConnected
        }
        cleanup(reason: SSEConnectionState.DisconnectReason.manuallyDisconnected)
    }

    public func terminate() async {
        cleanup(reason: .terminated)
        eventsContinuation.finish()
        stateEventContinuation.finish()
    }

    public var events: AsyncStream<ServerSentEvent> {
        eventsStream
    }

    public var stateEvents: AsyncStream<SSEConnectionState> {
        stateEventStream
    }

    // MARK: Helpers

    private func startStreamingLoop(bytes: AsyncStream<UInt8>) {
        streamingTask = Task(priority: .high) {
            do {
                // Using our new extension to keep the logic identical to your original intent
                for try await line in bytes.lines {
                    guard !Task.isCancelled else { break }

                    // Since SSEParser is an actor, we await the result
                    let event = await parser.parseLine(line)

                    if let event {
                        eventsContinuation.yield(event)
                        if let id = event.id {
                            lastEventId = id
                        }
                    }
                }

                handleDisconnection(reason: .streamEnded)
            } catch {
                guard !Task.isCancelled else { return }
                handleDisconnection(reason: .streamError(error))
            }
        }
    }

    private func handleDisconnection(reason: SSEConnectionState.DisconnectReason) {
        guard case .connected = connectionState else { return }
        cleanup(reason: reason)
    }

    /// Cancels the streaming task and transitions to disconnected state.
    /// Does NOT finish continuations, allowing the client to reconnect later.
    private func cleanup(reason: SSEConnectionState.DisconnectReason) {
        streamingTask?.cancel()
        streamingTask = nil
        connectionState = .disconnected(reason)
        // Note: Do NOT finish continuations here - allows reconnection
    }
}
