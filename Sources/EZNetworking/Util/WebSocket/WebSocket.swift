import Foundation

public actor WebSocketEngine: WebSocketClient {
    // Dependencies
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private let requestDecoder: RequestDecodable
    
    // Delegate & Interceptors
    private var sessionDelegate: SessionDelegate
    private var fallbackWebSocketTaskInterceptor = DefaultWebSocketTaskInterceptor()
    
    // Task
    private var webSocketTask: WebSocketTaskProtocol? // URLSessionWebSocketTask protocol
    
    // AsyncStream Continuations
    private var messageContinuation: AsyncStream<InboundMessage>.Continuation?
    private var connectionStateContinuation: AsyncStream<WebSocketConnectionState>.Continuation?
    
    // Connection handling
    private var connectionContinuation: CheckedContinuation<String?, Error>?
    
    // State
    private var connectionState: WebSocketConnectionState = .idle
    
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
        validator: ResponseValidator = ResponseValidatorImpl(),
        requestDecoder: RequestDecodable = RequestDecoder(),
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
        self.validator = validator
        self.requestDecoder = requestDecoder
        
//        // Set up the event handler ONCE during initialization
//        setupWebSocketEventHandler()
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
    
    private var eventHandlerSetup = false  // Track if handler is set up
    
    /// Sets up the WebSocket event handler that handles ALL events throughout the lifecycle
    private func setupWebSocketEventHandler() {
        guard !eventHandlerSetup else { return }
        eventHandlerSetup = true
        
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
    /// Routes events based on current connection state
    private func handleWebSocketEvent(_ event: WebSocketTaskEvent) async {
        switch connectionState {
        case .idle:
            // No connection attempt in progress, ignore events
            break
            
        case .connecting:
            // Initial connection phase - handle connection establishment or failure
            await handleInitialConnectionEvent(event)
            
        case .connected:
            // Connection is active - handle disconnection events
            await handleOngoingConnectionEvent(event)
            
        case .disconnected, .connectionLost, .failed:
            // Already disconnected, ignore further events
            break
        }
    }
    
    /// Handles events during initial connection phase
    private func handleInitialConnectionEvent(_ event: WebSocketTaskEvent) async {
        guard let continuation = connectionContinuation else { return }
        
        // Clear the continuation so we only handle the first event
        connectionContinuation = nil
        
        switch event {
        case .didOpenWithProtocol(let proto):
            continuation.resume(returning: proto)
            
        case .didOpenWithError(let err):
            let error = WebSocketError.connectionFailed(underlying: err)
            continuation.resume(throwing: error)
            
        case .didClose(let code, let reason):
            let reasonStr = reason.flatMap { String(data: $0, encoding: .utf8) }
            let error = WebSocketError.unexpectedDisconnection(code: code, reason: reasonStr)
            continuation.resume(throwing: error)
        }
    }
    
    /// Handles events after connection is established
    private func handleOngoingConnectionEvent(_ event: WebSocketTaskEvent) async {
        switch event {
        case .didOpenWithProtocol, .didOpenWithError:
            // Shouldn't happen when already connected, but ignore
            break
            
        case .didClose(let code, let reason):
            // Server explicitly closed or OS detected closure
            let reasonStr = reason.flatMap { String(data: $0, encoding: .utf8) }
            let error = WebSocketError.unexpectedDisconnection(code: code, reason: reasonStr)
            
            await handleConnectionLoss(error: error)
        }
    }
    
    // MARK: Connection
    
    public func connect(with url: URL, protocols: [String] = []) async throws {
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
    
    /// user disconnects web socket connection
    public func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode = .normalClosure, reason: Data? = nil) async {
        updateConnectionState(.disconnected)
        webSocketTask?.cancel(with: closeCode, reason: reason)
        messageContinuation?.finish()
        connectionContinuation = nil
    }
    
    /// connection is lost. Internal
    private func handleConnectionLoss(error: WebSocketError) async {
        updateConnectionState(.connectionLost(reason: error))
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        messageContinuation?.finish()
        connectionContinuation = nil
    }
    
    // MARK: - Ping loop
    private func startPingLoop(intervalSeconds: UInt64) {
        Task { [weak self] in
            guard let self else { return }
            
            var consecutiveFailures = 0
            let maxFailures = 3
            
            while await self.isConnectedState() {
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
                
                try? await Task.sleep(nanoseconds: intervalSeconds * 1_000_000_000)
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

}

extension WebSocketEngine {
    // Helper to check if current state is connected
    private func isConnectedState() async -> Bool {
        if case .connected = connectionState { return true }
        return false
    }
}
