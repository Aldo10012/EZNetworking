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
    private let retryPolicy: RetryPolicy?
    private var retryIntervalGivenByServer: TimeInterval?

    // Streams
    private let eventsStream: AsyncStream<ServerSentEvent>
    private let eventsContinuation: AsyncStream<ServerSentEvent>.Continuation

    private let stateEventStream: AsyncStream<SSEConnectionState>
    private let stateEventContinuation: AsyncStream<SSEConnectionState>.Continuation

    /// Tracks the background task that consumes the byte stream and parses SSE events.
    private var streamingTask: Task<Void, Never>?

    // MARK: init

    public init(
        url: String,
        session: NetworkSession = Session(),
        retryPolicy: RetryPolicy? = nil,
        responseValidator: ResponseValidator = SSEResponseValidator()
    ) {
        self.init(
            request: SSERequest(url: url),
            session: session,
            retryPolicy: retryPolicy,
            responseValidator: responseValidator
        )
    }

    public init(
        request: SSERequest,
        session: NetworkSession = Session(),
        retryPolicy: RetryPolicy? = nil,
        responseValidator: ResponseValidator = SSEResponseValidator()
    ) {
        sseRequest = request
        self.session = session
        self.retryPolicy = retryPolicy
        self.responseValidator = responseValidator

        self.session.configuration.timeoutIntervalForRequest = 60 // Connection timeout 1 minute
        self.session.configuration.timeoutIntervalForResource = 86400 // 24-hour stream timeout
        self.session.configuration.httpShouldUsePipelining = false
        self.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

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
            throw NetworkingError.serverSentEventFailed(reason: .stillConnecting)
        }
        if case .connected = connectionState {
            throw NetworkingError.serverSentEventFailed(reason: .alreadyConnected)
        }
        connectionState = .connecting

        if let config = retryPolicy, config.enabled {
            try await attemptConnectWithReconnection(config: config)
        } else {
            try await attemptSingleConnect()
        }
    }

    public func disconnect() async throws {
        guard case .connected = connectionState else {
            throw NetworkingError.serverSentEventFailed(reason: .notConnected)
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
}

// MARK: - Helpers

/// extension contianing helper methods
extension ServerSentEventManager {
    // MARK: connect

    private func attemptSingleConnect() async throws {
        do {
            sseRequest.setLastEventId(lastEventId)
            let request = try sseRequest.getURLRequest()
            let (bytesStream, response) = try await session.urlSession.bytes(for: request)

            try responseValidator.validateStatus(from: response)
            connectionState = .connected

            startStreamingLoop(bytes: bytesStream)
        } catch let netowrkingError as NetworkingError {
            connectionState = .disconnected(.streamError(netowrkingError))
            throw netowrkingError
        } catch {
            let error = NetworkingError.serverSentEventFailed(reason: .connectionFailed(underlying: error))
            connectionState = .disconnected(.streamError(error))
            throw error
        }
    }

    private func attemptConnectWithReconnection(config: RetryPolicy) async throws {
        var attemptCount: UInt = 0
        var lastError: Error?

        while true {
            if config.hasReachedMaxAttempts(attemptCount) {
                let fallbackError = NetworkingError.serverSentEventFailed(reason: .maxReconnectAttemptsReached)
                throw lastError ?? fallbackError
            }
            await waitWithDelayBeforeAttemptingReconnect(attemptCount: attemptCount, config: config)
            attemptCount += 1
            do {
                try await attemptSingleConnect()
                return
            } catch {
                lastError = error
                continue
            }
        }
    }

    private func waitWithDelayBeforeAttemptingReconnect(attemptCount: UInt, config: RetryPolicy) async {
        guard attemptCount > 0 else { return }

        if attemptCount == 1, let serverRetry = retryIntervalGivenByServer {
            try? await Task.sleep(nanoseconds: UInt64(serverRetry * 1_000_000_000))
        } else {
            let delay = config.calculateDelay(for: attemptCount) // Exponential backoff
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }

    // MARK: streaming loop

    private func startStreamingLoop(bytes: AsyncThrowingStream<UInt8, Error>) {
        streamingTask = Task(priority: .high) {
            do {
                for try await line in bytes.sseLines {
                    guard !Task.isCancelled else { break }

                    let event = await parser.parseLine(line)
                    if let event {
                        eventsContinuation.yield(event)
                        if let id = event.id {
                            lastEventId = id
                        }
                        if let retry = event.retry {
                            retryIntervalGivenByServer = TimeInterval(retry) / 1000.0 // Convert ms to seconds
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

    // MARK: disconnect / cleanup

    private func handleDisconnection(reason: SSEConnectionState.DisconnectReason) {
        guard case .connected = connectionState else { return }
        cleanup(reason: reason)

        switch reason {
        case .streamEnded, .streamError:
            guard let config = retryPolicy, config.enabled else { return }
            Task {
                await attemptReconnectionAfterStreamFailure(config: config)
            }
        default:
            break
        }
    }

    /// Cancels the streaming task and transitions to disconnected state.
    /// Does NOT finish continuations, allowing the client to reconnect later.
    private func cleanup(reason: SSEConnectionState.DisconnectReason) {
        streamingTask?.cancel()
        streamingTask = nil
        connectionState = .disconnected(reason)
        // Note: Do NOT finish continuations here - allows reconnection
    }

    /// Handles reconnection after an established stream fails.
    private func attemptReconnectionAfterStreamFailure(config: RetryPolicy) async {
        connectionState = .connecting
        var attemptCount: UInt = 0

        while true {
            if config.hasReachedMaxAttempts(attemptCount) {
                return // Give up silently (already disconnected)
            }
            await waitWithDelayBeforeAttemptingReconnect(attemptCount: attemptCount, config: config)
            attemptCount += 1
            do {
                try await attemptSingleConnect()
                return // Success!
            } catch {
                continue // Try again
            }
        }
    }
}
