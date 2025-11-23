import Foundation

public actor WebSocketEngine: WebSocketClient {
    // Dependencies
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private let requestDecoder: RequestDecodable
    private var sessionDelegate: SessionDelegate
        
    // Task
    private var webSocketTask: WebSocketTaskProtocol? // URLSessionWebSocketTask protocol

    // AsyncStream Continuation
    private var continuation: AsyncStream<URLSessionWebSocketTask.Message>.Continuation?

    // State
    private var streamCreated = false
    private var isConnected = false
    
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
        isConnected = false
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        continuation?.finish()
    }
    
    // MARK: Connection
    
    public func connect(with url: URL, protocols: [String] = []) async throws {
        guard !isConnected else { return }
        
        webSocketTask = urlSession.webSocketTaskInspectable(with: url, protocols: protocols)
        webSocketTask?.resume()
        isConnected = true
        
        // TODO: start ping loop
        startPingLoop(intervalSeconds: 30)
    }
    
    public func disconnect(with closeCode: URLSessionWebSocketTask.CloseCode = .normalClosure, reason: Data? = nil) async {
        // TODO: implement
        isConnected = false
        webSocketTask?.cancel(with: closeCode, reason: reason)
        continuation?.finish()
    }
    
    // MARK: Sending messages
    public func send(_ message: OutboundMessage) async throws {
        // TODO: implement
    }
    
    // MARK: - Receiving messages
    
    // MARK: - Helper methods
    func startPingLoop(intervalSeconds: UInt64) {
        Task {
            var consecutiveFailures = 0
            let maxFailures = 3
            
            while isConnected {
                do {
                    try await self.sendPing()
                    consecutiveFailures = 0
                } catch {
                    consecutiveFailures += 1
                }
                
                if consecutiveFailures >= maxFailures {
                    await self.disconnect(with: .goingAway)
                    continuation?.finish()
                    break
                }
                
                try? await Task.sleep(nanoseconds: intervalSeconds * 1_000_000_000)
            }
        }
    }
    
    /// Sends a single ping and waits for a pong response.
    func sendPing() async throws {
            guard let task = webSocketTask else {
                // TODO: create new WebSocket error type
                throw NetworkingError.internalError(.couldNotParse) // WebSocketError.notConnected
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
}
