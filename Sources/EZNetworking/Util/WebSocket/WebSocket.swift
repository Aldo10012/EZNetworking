import Foundation

public actor WebSocket: WebSocketClient {
    
    private let urlSession: URLSessionTaskProtocol
    private var sessionDelegate: SessionDelegate
    private let webSocketRequest: URLRequest
    
    private var webSocketTask: WebSocketTaskProtocol?
    private let fallbackWebSocketTaskInterceptor: WebSocketTaskInterceptor = DefaultWebSocketTaskInterceptor()
    private var connectionState: WebSocketConnectionState = .idle
    
    /// Used to suspend `connect()` until the delegate reports connection success/failure
    private var initialConnectionContinuation: CheckedContinuation<String?, Error>?
    
    // MARK: Init
    
    public init(
        urlRequest: URLRequest,
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        sessionDelegate: SessionDelegate? = nil
    ) {
        self.webSocketRequest = urlRequest
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
    
    // MARK: Connect
    
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

    }
    
    // handle open/close events
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
        case (.idle, _), (.disconnected, _), (.connectionLost, _), (.failed, _):
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
        connectionState = .failed(error: error)
    }
    
    private func parseReason(_ reason: Data?) -> String? {
        reason.flatMap { String(data: $0, encoding: .utf8) }
    }
    
    private func waitForConnection() async throws {
        connectionState = .connecting
        
        do {
            let connectedProtocol = try await withCheckedThrowingContinuation { continuation in
                self.initialConnectionContinuation = continuation
            }
            connectionState = .connected(protocol: connectedProtocol)
        } catch let wsError as WebSocketError {
            connectionState = .failed(error: wsError)
            throw wsError
        } catch {
            let wsError = WebSocketError.connectionFailed(underlying: error)
            connectionState = .failed(error: wsError)
            throw wsError
        }
    }
    
    // MARK: Disconnect
    
    public func disconnect(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async {
        // TODO: implement
    }
    
    private func handleConnectionLoss(error: WebSocketError) {
        cleanup(closeCode: .goingAway, reason: nil, newState: .connectionLost(reason: error), error: error)
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
        
        // Clear the event handler to prevent new tasks from being created
        sessionDelegate.webSocketTaskInterceptor?.onEvent = nil
    }
    
    // MARK: Send message
    
    public func send(_ message: OutboundMessage) async throws {
        // TODO: implement
    }
    
    // MARK: Receive messages
    
    public nonisolated var messages: AsyncThrowingStream<InboundMessage, any Error> {
        // TODO: implement
        AsyncThrowingStream<InboundMessage, Error> { $0.finish() }
    }
    
    // MARK: State events
    
    public nonisolated var stateEvents: AsyncStream<WebSocketConnectionState> {
        // TODO: implement
        AsyncStream<WebSocketConnectionState> { $0.finish() }
    }
}
