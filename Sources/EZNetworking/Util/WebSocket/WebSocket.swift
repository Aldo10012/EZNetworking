import Foundation

public actor WebSocket: WebSocketClient {
    
    private let urlSession: URLSessionTaskProtocol
    private nonisolated let sessionDelegate: SessionDelegate
    private let webSocketRequest: WebSocketRequest
    
    private var webSocketTask: WebSocketTaskProtocol?
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
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        sessionDelegate: SessionDelegate? = nil
    ) {
        self.init(request: WebSocketRequest(url: url, protocols: protocols, additionalheaders: additionalheaders),
                  pingConfig: pingConfig,
                  urlSession: urlSession,
                  sessionDelegate: sessionDelegate)
    }
    public init(
        request: WebSocketRequest,
        pingConfig: PingConfig = PingConfig(),
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        sessionDelegate: SessionDelegate? = nil
    ) {
        self.webSocketRequest = request
        self.pingConfig = pingConfig
        if let urlSession = urlSession as? URLSession {
            // If the session already has a delegate, use it (if it's a SessionDelegate)
            if let existingDelegate = urlSession.delegate as? SessionDelegate {
                self.sessionDelegate = existingDelegate
                self.urlSession = urlSession
            } else {
                // If no delegate or not a SessionDelegate, create one
                let newDelegate = sessionDelegate ?? SessionDelegate()
                let newSession = URLSession(
                    configuration: urlSession.configuration,
                    delegate: newDelegate,
                    delegateQueue: urlSession.delegateQueue
                )
                self.sessionDelegate = newDelegate
                self.urlSession = newSession
            }
        } else {
            // For mocks or custom protocol types
            self.sessionDelegate = sessionDelegate ?? SessionDelegate()
            self.urlSession = urlSession
        }
        
        let (messagesStream, messagesContinuation) = AsyncStream<InboundMessage>.makeStream()
        self.messagesStream = messagesStream
        self.messagesContinuation = messagesContinuation
        
        let (stream, continuation) = AsyncStream<WebSocketConnectionState>.makeStream()
        self.stateEventStream = stream
        self.stateEventContinuation = continuation
        
        setupWebSocketEventHandler()
    }
    
    // MARK: deinit
    
    deinit {
        sessionDelegate.webSocketTaskInterceptor?.onEvent = nil
        stateEventContinuation.finish()
        messagesContinuation.finish()
    }
    
    // MARK: - Connect
    
    public func connect() async throws {
        let urlRequest = try webSocketRequest.getURLRequest()
        
        // Validate current state
        if case .connecting = connectionState {
            throw WebSocketError.stillConnecting
        }
        if case .connected(protocol: _) = connectionState {
            throw WebSocketError.alreadyConnected
        }
        
        // Create and resume WebSocket task
        webSocketTask = urlSession.webSocketTaskInspectable(with: urlRequest)
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
        if sessionDelegate.webSocketTaskInterceptor == nil {
            sessionDelegate.webSocketTaskInterceptor = fallbackWebSocketTaskInterceptor
        }
        guard sessionDelegate.webSocketTaskInterceptor?.onEvent == nil else {
            return
        }
        
        sessionDelegate.webSocketTaskInterceptor?.onEvent = { [weak self] event in
            Task {
                await self?.handleWebSocketInterceptorEvent(event)
            }
        }
    }
    
    private func handleWebSocketInterceptorEvent(_ event: WebSocketTaskEvent) async {
        switch (connectionState, event) {
        case (.notConnected, _), (.disconnected, _):
            break
            
        case (.connecting, .didOpenWithProtocol(let proto)):
            handleConnect(with: proto)
            
        case (.connecting, .didOpenWithError(let err)):
            handleConnectFail(throwing: .connectionFailed(underlying: err))
            
        case (.connecting, .didClose(let code, let reason)):
            handleConnectFail(throwing: .unexpectedDisconnection(code: code, reason: parseReason(reason)))
            
        case (.connected, .didClose(let code, let reason)):
            let error = WebSocketError.unexpectedDisconnection(code: code, reason: parseReason(reason))
            handleConnectionLoss(error: error)
            
        case (.connected, _):
            break
        }
    }
    
    private func handleConnect(with protocolStr: String?) {
        initialConnectionContinuation?.resume(returning: protocolStr)
        initialConnectionContinuation = nil
    }
    
    private func handleConnectFail(throwing error: WebSocketError) {
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
        } catch let wsError as WebSocketError {
            connectionState = .disconnected(.failedToConnect(error: wsError))
            throw wsError
        } catch {
            let wsError = WebSocketError.connectionFailed(underlying: error)
            connectionState = .disconnected(.failedToConnect(error: wsError))
            throw wsError
        }
    }
    
    // MARK: Ping-pong loop
    
    private func startPingLoop() {
        pingTask = Task(priority: .high) {
            var consecutiveFailures = 0
            var lastError: WebSocketError? = nil
            while !Task.isCancelled, let wsTask = webSocketTask, case .connected = connectionState {
                // Check if ping failed too many times in a row
                if consecutiveFailures >= pingConfig.maxPingFailures {
                    self.handleConnectionLoss(error: lastError ?? WebSocketError.pongTimeout)
                    break
                }
                do {
                    try await wsTask.sendPing()
                    consecutiveFailures = 0
                    lastError = nil
                } catch {
                    guard !Task.isCancelled else { break }
                    consecutiveFailures += 1
                    lastError = WebSocketError.pingFailed(underlying: error)
                }
                await pingConfig.waitForPingInterval()
            }
        }
    }
    
    // MARK: - Disconnect
    
    public func disconnect() async throws {
        guard case .connected = connectionState else {
            throw WebSocketError.notConnected
        }
        
        cleanup(closeCode: .normalClosure,
                reason: nil,
                newState: .disconnected(.manuallyDisconnected),
                error: .forcedDisconnection)
    }
    
    private func handleConnectionLoss(error: WebSocketError) {
        guard case .connected = connectionState else { return }
        
        let closeCode = webSocketTask?.closeCode ?? .goingAway
        let reason = webSocketTask?.closeReason ?? nil
        cleanup(closeCode: closeCode,
                reason: reason,
                newState: .disconnected(.connectionLost(error: error)),
                error: error)
    }
    
    /// cleanup() is meant to clean up tasks and continuations, marking the WebSocket as disconnected.
    /// cleanup() does NOT finish stateEventContinuation or messagesContinuation.
    /// This allows the streams to persist after disconnect and reconnect
    private func cleanup(
        closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?,
        newState: WebSocketConnectionState,
        error: WebSocketError
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
        cleanup(closeCode: .normalClosure, reason: nil,
                newState: .disconnected(.terminated),
                error: .forcedDisconnection)
        sessionDelegate.webSocketTaskInterceptor?.onEvent = nil
        stateEventContinuation.finish()
        messagesContinuation.finish()
    }
    
    // MARK: - Send message
    
    public func send(_ message: OutboundMessage) async throws {
        guard let wsTask = webSocketTask, case .connected = connectionState else {
            throw WebSocketError.notConnected
        }
        
        do {
            try await wsTask.send(message)
        } catch {
            throw WebSocketError.sendFailed(underlying: error)
        }
    }
    
    // MARK: - Receive messages

    public var messages: AsyncStream<InboundMessage> {
        return messagesStream
    }
    
    private func startReceiveMessagesLoop() {
        receiveMessagesTask = Task(priority: .high) {
            while !Task.isCancelled, let wsTask = webSocketTask, case .connected = connectionState {
                do {
                    let message = try await wsTask.receive()
                    messagesContinuation.yield(message)
                } catch {
                    guard !Task.isCancelled else { break }
                    let wsError = WebSocketError.receiveFailed(underlying: error)
                    handleConnectionLoss(error: wsError)
                    break
                }
            }
        }
    }
    
    // MARK: - State events
    
    public var stateEvents: AsyncStream<WebSocketConnectionState> {
        return stateEventStream
    }
}
