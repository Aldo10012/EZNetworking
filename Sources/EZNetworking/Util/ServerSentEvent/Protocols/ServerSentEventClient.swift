import Foundation

/// A client interface for managing Server-Sent Event (SSE) connection lifecycles and event delivery.
public protocol ServerSentEventClient {
    
    /// Initiates a connection to the SSE endpoint or throws if already active.
    func connect() async throws
    
    /// Gracefully closes the active connection without finalizing the client.
    func disconnect() async throws
    
    /// Permanently shuts down the client and releases all internal resources.
    func terminate() async
    
    /// An asynchronous stream of all events received from the server.
    var events: AsyncStream<ServerSentEvent> { get }
    
    /// An asynchronous stream that monitors connection state transitions.
    var stateEvents: AsyncStream<SSEConnectionState> { get }
}