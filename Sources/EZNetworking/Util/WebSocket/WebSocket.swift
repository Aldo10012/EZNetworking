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

    // AsyncStream Continuation
    private var continuation: AsyncStream<URLSessionWebSocketTask.Message>.Continuation?

    // State
    private var connectionState: WebSocketConnectionState = .disconnected
    
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
    }
    
    deinit {
        connectionState = .disconnected
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        continuation?.finish()
    }
    
    // MARK: Connection
    
    public func connect(with url: URL, protocols: [String] = []) async throws {
        if case .connected(protocol: _) = connectionState {
            throw WebSocketError.alreadyConnected
        }
        
        webSocketTask = urlSession.webSocketTaskInspectable(with: url, protocols: protocols)
        
        // Ensure there's an interceptor to observe open/close events
        if sessionDelegate.webSocketTaskInterceptor == nil {
            sessionDelegate.webSocketTaskInterceptor = fallbackWebSocketTaskInterceptor
        }
        
        // establish web socket connection
        do {
            let proto = try await waitForConnection()
            connectionState = .connected(protocol: proto)
        } catch let wsError as WebSocketError {
            connectionState = .failed(error: wsError)
            throw wsError
        } catch {
            connectionState = .failed(error: .connectionFailed(underlying: error))
            throw WebSocketError.connectionFailed(underlying: error)
        }

        // now that web socket connection is established, set up pinp-pong to keep connection alive
        startPingLoop(intervalSeconds: 30)
    }

    private func waitForConnection() async throws -> String? {
        guard let task = webSocketTask else {
            throw WebSocketError.taskNotInitialized
        }

        do {
            let proto = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String?, Error>) in
                var resumed = false

                sessionDelegate.webSocketTaskInterceptor?.onEvent = { event in
                    guard !resumed else { return }
                    resumed = true
                    switch event {
                    case .didOpen(let proto):
                        continuation.resume(returning: proto)
                        
                    case .didClose(let code, let reason):
                        let reasonStr = reason.flatMap { String(data: $0, encoding: .utf8) }
                        let err = WebSocketError.unexpectedDisconnection(code: code, reason: reasonStr)
                        continuation.resume(throwing: err)
                    }
                }

                // Resume the task after the handler is installed to avoid races
                task.resume()
            }

            // clear handler
            sessionDelegate.webSocketTaskInterceptor?.onEvent = { _ in }
            return proto
        } catch {
            throw WebSocketError.connectionFailed(underlying: error)
        }
    }
    
    // MARK: Disconnect
    
    /// user disconnects web socket connection
    public func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode = .normalClosure, reason: Data? = nil) async {
        connectionState = .disconnected
        webSocketTask?.cancel(with: closeCode, reason: reason)
        continuation?.finish()
    }
    
    /// connection is lost. Internal
    private func handleConnectionLoss(error: WebSocketError) async {
        connectionState = .connectionLost(reason: error)
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        continuation?.finish()
    }
    
    // MARK: - Ping loop
    private func startPingLoop(intervalSeconds: UInt64) {
        Task {
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
