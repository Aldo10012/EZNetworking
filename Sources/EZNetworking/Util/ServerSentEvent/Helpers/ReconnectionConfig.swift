import Foundation

/// Configuration for automatic SSE reconnection using exponential backoff.
public struct ReconnectionConfig: Sendable {
    /// Flag to enable or disable automatic reconnection attempts after errors.
    public let enabled: Bool
    /// The limit of retry attempts, or nil for infinite retries.
    public let maxAttempts: Int?
    /// The starting wait time in seconds before the first retry attempt.
    public let initialDelay: TimeInterval
    /// The upper limit for the delay duration between reconnection attempts.
    public let maxDelay: TimeInterval
    /// The factor by which the delay increases after each failed attempt.
    public let backoffMultiplier: Double
    
    public init(
        enabled: Bool = true,
        maxAttempts: Int? = nil,
        initialDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 60.0,
        backoffMultiplier: Double = 2.0
    ) {
        self.enabled = enabled
        self.maxAttempts = maxAttempts
        self.initialDelay = initialDelay
        self.maxDelay = maxDelay
        self.backoffMultiplier = backoffMultiplier
    }
}