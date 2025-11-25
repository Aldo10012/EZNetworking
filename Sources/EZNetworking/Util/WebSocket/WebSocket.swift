import Foundation

public actor WebSocketEngine: WebSocketClient {
    // Dependencies
    private let urlSession: URLSessionTaskProtocol
    
    // Delegate & Interceptors
    private var sessionDelegate: SessionDelegate
    private var fallbackWebSocketTaskInterceptor = DefaultWebSocketTaskInterceptor()
    
    // Task
    private var webSocketTask: WebSocketTaskProtocol? // URLSessionWebSocketTask protocol
    
    // AsyncStream Continuations
    private var messageContinuation: AsyncThrowingStream<InboundMessage, Error>.Continuation?
    private var connectionStateContinuation: AsyncStream<WebSocketConnectionState>.Continuation?
    
    // Connection handling
    private var connectionContinuation: CheckedContinuation<String?, Error>?
    
    // State
    private var connectionState: WebSocketConnectionState = .idle
    private var messageStreamCreated = false
    
    // Connection state stream
    public private(set) lazy var connectionStateStream: AsyncStream<WebSocketConnectionState> = {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }
            Task {
                await self.setConnectionStateContinuation(continuation)
                let currentState = await self.connectionState
                continuation.yield(currentState)
            }
        }
    }()
    
    // MARK: init
    
    public init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        sessionDelegate: SessionDelegate? = nil // Now optional!
    ) {
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
    }
    
    deinit {
        connectionState = .disconnected
        connectionStateContinuation?.finish()
        messageContinuation?.finish()
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
    
    // MARK: Connection State Management
    
    private func setConnectionStateContinuation(_ continuation: AsyncStream<WebSocketConnectionState>.Continuation) {
        self.connectionStateContinuation = continuation
    }
    
    private func updateConnectionState(_ newState: WebSocketConnectionState) {
        connectionState = newState
        connectionStateContinuation?.yield(newState)
    }
    
    // MARK: Event Handler Setup (Called ONCE)
        
    /// Sets up the WebSocket event handler that handles ALL events throughout the lifecycle
    private func setupWebSocketEventHandler() {
        guard sessionDelegate.webSocketTaskInterceptor?.onEvent == nil else { return }
        
        if sessionDelegate.webSocketTaskInterceptor == nil {
            sessionDelegate.webSocketTaskInterceptor = fallbackWebSocketTaskInterceptor
        }
        
        sessionDelegate.webSocketTaskInterceptor?.onEvent = { [weak self] event in
            Task {
                await self?.handleWebSocketEvent(event)
            }
        }
    }
    
    /// Central event handler for ALL WebSocket events
    private func handleWebSocketEvent(_ event: WebSocketTaskEvent) async {
        switch (connectionState, event) {
        // Ignore events when not actively connecting/connected
        case (.idle, _), (.disconnected, _), (.connectionLost, _), (.failed, _):
            break
            
        // Initial connection phase
        case (.connecting, .didOpenWithProtocol(let proto)):
            resumeConnection(with: proto)
            
        case (.connecting, .didOpenWithError(let err)):
            resumeConnection(throwing: .connectionFailed(underlying: err))
            
        case (.connecting, .didClose(let code, let reason)):
            resumeConnection(throwing: .unexpectedDisconnection(code: code, reason: parseReason(reason)))
            
        // Active connection phase
        case (.connected, .didClose(let code, let reason)):
            await handleConnectionLoss(error: .unexpectedDisconnection(code: code, reason: parseReason(reason)))
            
        case (.connected, _):
            break // Ignore redundant open events when already connected
        }
    }

    private func resumeConnection(with protocol: String?) {
        connectionContinuation?.resume(returning: `protocol`)
        connectionContinuation = nil
    }

    private func resumeConnection(throwing error: WebSocketError) {
        connectionContinuation?.resume(throwing: error)
        connectionContinuation = nil
    }

    private func parseReason(_ reason: Data?) -> String? {
        reason.flatMap { String(data: $0, encoding: .utf8) }
    }
    
    // MARK: Connection
    
    public func connect(with url: URL) async throws {
        try await connect(with: url, protocols: [])
    }
    
    public func connect(with url: URL, protocols: [String]) async throws {
        // Step 1: Check if already connected to web socket
        if case .connected(protocol: _) = connectionState {
            throw WebSocketError.alreadyConnected
        }
        
        // Step 2: Set up open/close event listener
        setupWebSocketEventHandler()
        
        // Step 3: Set connection state to .connecting
        updateConnectionState(.connecting)
        
        // Step 4: Create URLWebSocketTask
        webSocketTask = urlSession.webSocketTaskInspectable(with: url, protocols: protocols)
        
        // Step 5: Wait for initial connection to establish, throw error if connection error
        let proto = try await waitForConnection()
        
        // Step 6: update connection state to .connected
        updateConnectionState(.connected(protocol: proto))
        
        // Step 7: set up ping-pong to keep connection alive
        startPingLoop(intervalSeconds: 30)
    }
    
    private func waitForConnection() async throws -> String? {
        guard let task = webSocketTask else {
            throw WebSocketError.taskNotInitialized
        }
        
        do {
            let proto: String? = try await withCheckedThrowingContinuation { continuation in
                // Store the continuation so handleInitialConnectionEvent can resume it
                self.connectionContinuation = continuation
                
                // Resume the task - events will be routed through handleWebSocketEvent
                task.resume()
            }
            
            return proto
        } catch {
            // Ensure continuation is cleared on error
            connectionContinuation = nil
            throw error
        }
    }
    
    // MARK: Disconnect
    
    public func disconnect() async {
        await disconnect(with: .normalClosure, reason: nil)
    }
    
    /// user disconnects web socket connection
    public func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async {
        await _disconnect(with: closeCode, newConnectionState: .disconnected, reason: reason)
    }
    
    /// connection is lost. Internal
    private func handleConnectionLoss(error: WebSocketError) async {
        await _disconnect(with: .goingAway, newConnectionState: .connectionLost(reason: error), reason: nil)
    }
    
    /// handle updating cancellation state and cancelling continuations
    public func _disconnect(with closeCode: URLSessionWebSocketTask.CloseCode,
                            newConnectionState: WebSocketConnectionState,
                            reason: Data?) async {
        updateConnectionState(newConnectionState)
        webSocketTask?.cancel(with: closeCode, reason: reason)
        
        connectionContinuation = nil

        messageContinuation?.finish()
        messageContinuation = nil
        messageStreamCreated = false
        
        pingTask?.cancel()
    }
    
    // MARK: - Ping loop
    
    private var pingTask: Task<Void, Never>?
    
    private func startPingLoop(intervalSeconds: UInt64) {
        pingTask?.cancel() // just in case — avoid duplicates
        
        pingTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                var consecutiveFailures = 0
                let maxFailures = 3
                
                while await self.isConnectedState() {
                    try Task.checkCancellation()

                    do {
                        try await self.sendPing()
                        consecutiveFailures = 0
                    } catch {
                        consecutiveFailures += 1
                    }
                    
                    if consecutiveFailures >= maxFailures {
                        let error = WebSocketError.keepAliveFailure(consecutiveFailures: consecutiveFailures)
                        await self.handleConnectionLoss(error: error)
                        break
                    }

                    try Task.checkCancellation()
                    try await Task.sleep(nanoseconds: intervalSeconds * 1_000_000_000)
                }
            } catch {
                // Task was cancelled — nothing to do
            }
        }
    }
    
    /// Sends a single ping and waits for a pong response.
    private func sendPing() async throws {
        guard let task = webSocketTask else {
            throw WebSocketError.taskNotInitialized
        }
        
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                task.sendPing { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        } catch {
            throw WebSocketError.pingFailed(underlying: error)
        }
    }
    
    // MARK: Sending messages
    public func send(_ message: OutboundMessage) async throws {
        guard case .connected = connectionState else {
            throw WebSocketError.notConnected
        }
        
        guard let task = webSocketTask else {
            throw WebSocketError.taskNotInitialized
        }
        
        do {
            try await task.send(message)
        } catch {
            throw WebSocketError.sendFailed(underlying: error)
        }
    }
    
    // MARK: - Receiving messages
    
    nonisolated public func receiveMessages() -> AsyncThrowingStream<InboundMessage, Error> {
        return AsyncThrowingStream<InboundMessage, Error> { continuation in
            let task = Task { [weak self] in
                guard let self else {
                    continuation.finish()
                    return
                }
                await self.setMessageContinuation(continuation)
                await self.startReceivingMessages(continuation)
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    // Helper to set continuation on actor
    private func setMessageContinuation(
        _ continuation: AsyncThrowingStream<InboundMessage, Error>.Continuation
    ) async {
        guard case .connected = connectionState else {
            continuation.finish(throwing: WebSocketError.notConnected)
            return
        }
        guard !messageStreamCreated else {
            continuation.finish(throwing: WebSocketError.streamAlreadyCreated)
            return
        }
        
        self.messageContinuation = continuation
        messageStreamCreated = true

    }
    
    private func startReceivingMessages(
        _ continuation: AsyncThrowingStream<InboundMessage, Error>.Continuation
    ) async {
        guard let task = webSocketTask else {
            continuation.finish(throwing: WebSocketError.notConnected)
            return
        }
        
        while await isConnectedState() {
            do {
                let message = try await task.receive()
                continuation.yield(message)
            } catch {
                let wsError = WebSocketError.receiveFailed(underlying: error)
                
                print("Receive failed: \(wsError)")
                
                // Notify the engine that the connection is no longer valid
                await handleConnectionLoss(error: wsError)
                
                // IMPORTANT: finish WITH an error
                continuation.finish(throwing: wsError)
                return
            }
        }
        
        // If loop exits, connection state changed
        continuation.finish()
    }

    
    
//    nonisolated public func receiveMessage() -> AsyncStream<InboundMessage> {
//        AsyncStream { continuation in
//            Task { [weak self] in
//                guard let self else {
//                    continuation.finish()
//                    return
//                }
//                await self.startReceivingMessages(continuation)
//            }
//        }
//    }
//
//    private func startReceivingMessages(_ continuation: AsyncStream<InboundMessage>.Continuation) async {
//        guard let task = webSocketTask else {
//            continuation.finish()
//            return
//        }
//        self.messageContinuation = continuation
//
//        while await isConnectedState() {
//            do {
//                let message = try await task.receive()
//                continuation.yield(message)
//            } catch {
//                continuation.finish()
//                await handleConnectionLoss(error: .receiveFailed(underlying: error))
//                return
//            }
//        }
//
//        continuation.finish()
//    }
}

extension WebSocketEngine {
    // Helper to check if current state is connected
    private func isConnectedState() async -> Bool {
        if case .connected = connectionState { return true }
        return false
    }
}
