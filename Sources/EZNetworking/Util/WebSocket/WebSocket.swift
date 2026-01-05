import Foundation

public actor WebSocket: WebSocketClient {
    
    private let urlSession: URLSessionTaskProtocol
    private var sessionDelegate: SessionDelegate
    private let webSocketRequest: URLRequest
    
    private var webSocketTask: WebSocketTaskProtocol?
    private let fallbackWebSocketTaskInterceptor: WebSocketTaskInterceptor = DefaultWebSocketTaskInterceptor()
    
    private var connectionState: WebSocketConnectionState = .notConnected {
        didSet {
            stateEventContinuation.yield(connectionState)
        }
    }
    private nonisolated(unsafe) let stateEventStream: AsyncStream<WebSocketConnectionState>
    private let stateEventContinuation: AsyncStream<WebSocketConnectionState>.Continuation
    
    /// Used to suspend `connect()` until the delegate reports connection success/failure
    private var initialConnectionContinuation: CheckedContinuation<String?, Error>?
    
    private let pingConfig: PingConfig
    private var pingTask: Task<Void, Never>?
    
    private nonisolated(unsafe) var messagesStream: AsyncThrowingStream<InboundMessage, any Error>
    private let messagesContinuation: AsyncThrowingStream<InboundMessage, Error>.Continuation
    
    // MARK: Init
    
    public init(
        urlRequest: URLRequest,
        pingConfig: PingConfig = PingConfig(),
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        sessionDelegate: SessionDelegate? = nil
    ) {
        self.webSocketRequest = urlRequest
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
        
        let (messagesStream, messagesContinuation) = AsyncThrowingStream.makeStream(
            of: InboundMessage.self,
            throwing: Error.self
        )
        self.messagesStream = messagesStream
        self.messagesContinuation = messagesContinuation
        
        let (stream, continuation) = AsyncStream<WebSocketConnectionState>.makeStream()
        self.stateEventStream = stream
        self.stateEventContinuation = continuation
    }
    
    // MARK: - Connect
    
    public func connect() async throws {
        // Validate current state
        if case .connecting = connectionState {
            throw WebSocketError.stillConnecting
        }
        if case .connected(protocol: _) = connectionState {
            throw WebSocketError.alreadyConnected
        }
        
        // Create and resume WebSocket task
        webSocketTask = urlSession.webSocketTaskInspectable(with: webSocketRequest)
        webSocketTask?.resume()
        
        // set up delegate to observe connection success/failure
        setupWebSocketEventHandler()
        
        // wait for connection to establish
        try await waitForConnection()

        // start ping-ping loop
        startPingLoop()
        
        // start messages loop
        startReceiveMessagesLoop()
    }
    
    // MARK: Handle delegate events
    private func setupWebSocketEventHandler() {
        if sessionDelegate.webSocketTaskInterceptor == nil {
            sessionDelegate.webSocketTaskInterceptor = fallbackWebSocketTaskInterceptor
        }
        guard sessionDelegate.webSocketTaskInterceptor?.onEvent == nil else { return }
        
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
    
    private func startPingLoop(consecutiveFailures: Int = 0, lastError: WebSocketError? = nil) {
        pingTask = Task {
            guard !Task.isCancelled else { return }
            guard case .connected = connectionState else { return }
            
            // check if ping failed too many times in a row
            guard consecutiveFailures < pingConfig.maxPingFailures else {
                let err = lastError ?? WebSocketError.pongTimeout
                self.handleConnectionLoss(error: err)
                return
            }
            
            // send ping
            var totalConsecutiveFailures = consecutiveFailures
            var pingError: WebSocketError? = nil
            do {
                try await sendPing()
                totalConsecutiveFailures = 0
            } catch {
                totalConsecutiveFailures += 1
                pingError = WebSocketError.pingFailed(underlying: error)
            }
            
            await pingConfig.waitForPingInterval()
            startPingLoop(consecutiveFailures: totalConsecutiveFailures, lastError: pingError)
        }
    }
    
    private func sendPing() async throws {
        guard let task = webSocketTask else {
            throw WebSocketError.taskNotInitialized
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            task.sendPing { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Disconnect
    
    public func disconnect() async throws {
        guard case .connected = connectionState else {
            throw WebSocketError.notConnected
        }
        
        cleanup(closeCode: .goingAway,
                reason: nil,
                newState: .disconnected(.manuallyDisconnected),
                error: .forcedDisconnection)
    }
    
    private func handleConnectionLoss(error: WebSocketError) {
        let closeCode = webSocketTask?.closeCode ?? .goingAway
        let reason = webSocketTask?.closeReason ?? nil
        cleanup(closeCode: closeCode,
                reason: reason,
                newState: .disconnected(.connectionLost(error: error)),
                error: error)
    }
    
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
        
        stateEventContinuation.finish()
        
        pingTask?.cancel()
        pingTask = nil
        
        messagesContinuation.finish()
        receiveMessagesTask?.cancel()
        receiveMessagesTask = nil
        
        // Clear the event handler to prevent new tasks from being created
        sessionDelegate.webSocketTaskInterceptor?.onEvent = nil
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

    public nonisolated var messages: AsyncThrowingStream<InboundMessage, any Error> {
        return messagesStream
    }
    
    private var receiveMessagesTask: Task<Void, Never>?
    private func startReceiveMessagesLoop() {
        receiveMessagesTask = Task {
            guard !Task.isCancelled,
                  let task = webSocketTask,
                  case .connected = connectionState else {
                messagesContinuation.finish(throwing: WebSocketError.notConnected)
                return
            }
            
            do {
                let message = try await task.receive()
                messagesContinuation.yield(message)
                startReceiveMessagesLoop()
            } catch {
                let wsError = WebSocketError.receiveFailed(underlying: error)
                messagesContinuation.finish(throwing: wsError)
                handleConnectionLoss(error: wsError)
                return
            }
        }
    }
    
    // MARK: - State events
    
    public nonisolated var stateEvents: AsyncStream<WebSocketConnectionState> {
        return stateEventStream
    }
}
