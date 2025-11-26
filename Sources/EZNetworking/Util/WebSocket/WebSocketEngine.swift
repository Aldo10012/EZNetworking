import Foundation

public actor WebSocketEngine: WebSocketClient {
    
    private let urlSession: URLSessionTaskProtocol
    private let sessionDelegate: SessionDelegate?
    private var webSocketTask: WebSocketTaskProtocol?
    
    // Connectino State
    private var connectionState: WebSocketConnectionState = .idle

    
    // MARK: - init
    
    public init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        sessionDelegate: SessionDelegate? = nil
    ) {
        if let urlSession = urlSession as? URLSession {
            if let existingDelegate = urlSession.delegate as? SessionDelegate {
                self.sessionDelegate = existingDelegate
                self.urlSession = urlSession
            } else {
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
            self.sessionDelegate = sessionDelegate ?? SessionDelegate()
            self.urlSession = urlSession
        }
    }
    
    // MARK: - Connect
    
    public func connect(with url: URL, protocols: [String]) async throws {
        if case .connecting = connectionState {
            throw WebSocketError.stillConnecting
        }
        if case .connected(protocol: _) = connectionState {
            throw WebSocketError.alreadyConnected
        }
        
        webSocketTask = urlSession.webSocketTaskInspectable(with: url, protocols: protocols)
        webSocketTask?.resume()
        
        connectionState = .connecting
        
        try await waitForConnection()
        
        connectionState = .connected(protocol: "") // add protocol
        
        startPingLoop(intervalSeconds: 30)
    }
    
    // MARK: wait for connection
    
    private func waitForConnection() async throws {
        // TODO: listen for open event from the delegate
    }
    
    // MARK: ping loop
    
    private func startPingLoop(intervalSeconds: UInt64) {
        // TODO: set up ping-pong
    }
    
    // MARK: - Disconnect
    
    // TODO: Implement

    // MARK: - Send message
    
    // TODO: Implement

    // MARK: - Receive message
    
    // TODO: Implement

}
