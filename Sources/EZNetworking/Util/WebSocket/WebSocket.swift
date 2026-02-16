import Foundation

public actor WebSocket: WebSocketClient {
    private let session: NetworkSession
    private let webSocketRequest: WebSocketRequest

    private var webSocketTask: URLSessionWebSocketTaskProtocol?
    private nonisolated let fallbackWebSocketTaskInterceptor: WebSocketTaskInterceptor = DefaultWebSocketTaskInterceptor()

    private var connectionState: WebSocketConnectionState = .notConnected {
        didSet {
            stateEventContinuation.yield(connectionState)
        }
    }

    private let stateEventStream: AsyncStream<WebSocketConnectionState>
    private let stateEventContinuation: AsyncStream<WebSocketConnectionState>.Continuation

    /// Used to suspend `connect()` until the delegate reports connection success/failure
    private var initialConnectionContinuation: CheckedContinuation<String?, Error>?

    private let pingConfig: PingConfig
    private var pingTask: Task<Void, Never>?

    private var messagesStream: AsyncStream<InboundMessage>
    private let messagesContinuation: AsyncStream<InboundMessage>.Continuation
    private var receiveMessagesTask: Task<Void, Never>?

    // MARK: Init

    public init(
        url: String,
        protocols: [String]? = nil,
        additionalheaders: [HTTPHeader]? = nil,
        pingConfig: PingConfig = PingConfig(),
        session: NetworkSession = Session()
    ) {
        self.init(
            request: WebSocketRequest(url: url, protocols: protocols, additionalheaders: additionalheaders),
            pingConfig: pingConfig,
            session: session
        )
    }

    public init(
        request: WebSocketRequest,
        pingConfig: PingConfig = PingConfig(),
        session: NetworkSession = Session()
    ) {
        webSocketRequest = request
        self.pingConfig = pingConfig
        self.session = session

        let (messagesStream, messagesContinuation) = AsyncStream<InboundMessage>.makeStream()
        self.messagesStream = messagesStream
        self.messagesContinuation = messagesContinuation

        let (stream, continuation) = AsyncStream<WebSocketConnectionState>.makeStream()
        stateEventStream = stream
        stateEventContinuation = continuation

        setupWebSocketEventHandler()
    }

    // MARK: deinit

    deinit {
        session.delegate.webSocketTaskInterceptor?.onEvent = nil
        stateEventContinuation.finish()
        messagesContinuation.finish()
    }

    // MARK: - Connect

    public func connect() async throws {
        let urlRequest = try webSocketRequest.getURLRequest(allowedSchemes: .ws)

        // Validate current state
        if case .connecting = connectionState {
            throw WebSocketFailureReason.stillConnecting
        }
        if case .connected = connectionState {
            throw WebSocketFailureReason.alreadyConnected
        }

        // Create and resume WebSocket task
        webSocketTask = session.urlSession.webSocketTaskInspectable(with: urlRequest)
        webSocketTask?.resume()

        // wait for connection to establish
        try await waitForConnection()

        // start ping-ping loop
        startPingLoop()

        // start messages loop
        startReceiveMessagesLoop()
    }

    // MARK: Handle delegate events

    private nonisolated func setupWebSocketEventHandler() {
        if session.delegate.webSocketTaskInterceptor == nil {
            session.delegate.webSocketTaskInterceptor = fallbackWebSocketTaskInterceptor
        }
        guard session.delegate.webSocketTaskInterceptor?.onEvent == nil else {
            return
        }

        session.delegate.webSocketTaskInterceptor?.onEvent = { [weak self] event in
            Task { @Sendable [weak self] in
                await self?.handleWebSocketInterceptorEvent(event)
            }
        }
    }

    private func handleWebSocketInterceptorEvent(_ event: WebSocketTaskEvent) async {
        switch (connectionState, event) {
        case (.notConnected, _), (.disconnected, _):
            break

        case let (.connecting, .didOpenWithProtocol(proto)):
            handleConnect(with: proto)

        case let (.connecting, .didOpenWithError(err)):
            handleConnectFail(throwing: .connectionFailed(underlying: err))

        case let (.connecting, .didClose(code, reason)):
            handleConnectFail(throwing: .unexpectedDisconnection(code: code, reason: parseReason(reason)))

        case let (.connected, .didClose(code, reason)):
            let error = WebSocketFailureReason.unexpectedDisconnection(code: code, reason: parseReason(reason))
            handleConnectionLoss(error: error)

        case (.connected, _):
            break
        }
    }

    private func handleConnect(with protocolStr: String?) {
        initialConnectionContinuation?.resume(returning: protocolStr)
        initialConnectionContinuation = nil
    }

    private func handleConnectFail(throwing error: WebSocketFailureReason) {
        initialConnectionContinuation?.resume(throwing: error)
        initialConnectionContinuation = nil
    }

    private func parseReason(_ reason: Data?) -> String? {
        reason.flatMap { String(data: $0, encoding: .utf8) }
    }

    // MARK: Wait for connection

    private func waitForConnection() async throws {
        connectionState = .connecting

        do {
            let connectedProtocol = try await withCheckedThrowingContinuation { continuation in
                self.initialConnectionContinuation = continuation
            }
            connectionState = .connected(protocol: connectedProtocol)
        } catch let wsError as WebSocketFailureReason {
            connectionState = .disconnected(.failedToConnect(reason: wsError))
            throw wsError
        } catch {
            let wsError = WebSocketFailureReason.connectionFailed(underlying: error)
            connectionState = .disconnected(.failedToConnect(reason: wsError))
            throw wsError
        }
    }

    // MARK: Ping-pong loop

    private func startPingLoop() {
        pingTask = Task(priority: .high) {
            var consecutiveFailures = 0
            var lastError: WebSocketFailureReason?
            while !Task.isCancelled, let wsTask = webSocketTask, case .connected = connectionState {
                // Check if ping failed too many times in a row
                if consecutiveFailures >= pingConfig.maxPingFailures {
                    self.handleConnectionLoss(error: lastError ?? WebSocketFailureReason.pongTimeout)
                    break
                }
                do {
                    try await wsTask.sendPing()
                    consecutiveFailures = 0
                    lastError = nil
                } catch {
                    guard !Task.isCancelled else { break }
                    consecutiveFailures += 1
                    lastError = WebSocketFailureReason.pingFailed(underlying: error)
                }
                await pingConfig.waitForPingInterval()
            }
        }
    }

    // MARK: - Disconnect

    public func disconnect() async throws {
        guard case .connected = connectionState else {
            throw WebSocketFailureReason.notConnected
        }

        cleanup(
            closeCode: .normalClosure,
            reason: nil,
            newState: .disconnected(.manuallyDisconnected),
            error: .forcedDisconnection
        )
    }

    private func handleConnectionLoss(error: WebSocketFailureReason) {
        guard case .connected = connectionState else { return }

        let closeCode = webSocketTask?.closeCode ?? .goingAway
        let reason = webSocketTask?.closeReason
        cleanup(
            closeCode: closeCode,
            reason: reason,
            newState: .disconnected(.connectionLost(error: error)),
            error: error
        )
    }

    /// cleanup() is meant to clean up tasks and continuations, marking the WebSocket as disconnected.
    /// cleanup() does NOT finish stateEventContinuation or messagesContinuation.
    /// This allows the streams to persist after disconnect and reconnect
    private func cleanup(
        closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?,
        newState: WebSocketConnectionState,
        error: WebSocketFailureReason
    ) {
        initialConnectionContinuation?.resume(throwing: error)
        initialConnectionContinuation = nil

        webSocketTask?.cancel(with: closeCode, reason: reason)
        webSocketTask = nil

        connectionState = newState

        pingTask?.cancel()
        pingTask = nil

        receiveMessagesTask?.cancel()
        receiveMessagesTask = nil
    }

    // MARK: Terminate

    /// terminate() does the same as cleanup(), but ALSO finishes stateEventContinuation and messagesContinuation
    public func terminate() async {
        cleanup(
            closeCode: .normalClosure,
            reason: nil,
            newState: .disconnected(.terminated),
            error: .forcedDisconnection
        )
        session.delegate.webSocketTaskInterceptor?.onEvent = nil
        stateEventContinuation.finish()
        messagesContinuation.finish()
    }

    // MARK: - Send message

    public func send(_ message: OutboundMessage) async throws {
        guard let wsTask = webSocketTask, case .connected = connectionState else {
            throw WebSocketFailureReason.notConnected
        }

        do {
            try await wsTask.send(message)
        } catch {
            throw WebSocketFailureReason.sendFailed(underlying: error)
        }
    }

    // MARK: - Receive messages

    public var messages: AsyncStream<InboundMessage> {
        messagesStream
    }

    private func startReceiveMessagesLoop() {
        receiveMessagesTask = Task(priority: .high) {
            while !Task.isCancelled, let wsTask = webSocketTask, case .connected = connectionState {
                do {
                    let message = try await wsTask.receive()
                    messagesContinuation.yield(message)
                } catch {
                    guard !Task.isCancelled else { break }
                    let wsError = WebSocketFailureReason.receiveFailed(underlying: error)
                    handleConnectionLoss(error: wsError)
                    break
                }
            }
        }
    }

    // MARK: - State events

    public var stateEvents: AsyncStream<WebSocketConnectionState> {
        stateEventStream
    }
}
