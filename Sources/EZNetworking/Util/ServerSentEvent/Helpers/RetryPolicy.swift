import Foundation

/// Configuration for automatic reconnection behavior, including strategy and retry limits for SSE connections.
public struct RetryPolicy: Sendable {
    /// Determines if the client should automatically attempt to reconnect after unexpected stream errors.
    public let enabled: Bool
    /// The maximum number of retry attempts; set to nil for unlimited attempts.
    public let maxAttempts: UInt?
    /// The starting delay in seconds for the first reconnection attempt.
    public let initialDelay: TimeInterval
    /// The upper limit in seconds for the delay between reconnection attempts.
    public let maxDelay: TimeInterval
    /// The multiplier used to calculate exponential backoff for subsequent retries.
    public let backoffMultiplier: Double

    /// Initializes a new configuration with specific reconnection and backoff parameters.
    public init(
        enabled: Bool = true,
        maxAttempts: UInt? = nil,
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

extension RetryPolicy {
    /// Calculates the reconnection delay for a given attempt number.
    ///
    /// Uses exponential backoff: `initialDelay * backoffMultiplier^(attemptNumber - 1)`,
    /// capped at `maxDelay`.
    ///
    /// - Parameter attemptNumber: The current attempt number (1-indexed)
    /// - Returns: Delay in seconds before the next attempt
    func calculateDelay(for attemptNumber: UInt) -> TimeInterval {
        guard attemptNumber > 0 else { return 0 }

        let exponentialDelay = initialDelay * pow(
            backoffMultiplier,
            Double(attemptNumber - 1)
        )
        return min(exponentialDelay, maxDelay)
    }

    /// Checks if the maximum number of reconnection attempts has been reached.
    ///
    /// - Parameter currentAttemptCount: The number of attempts made so far
    /// - Returns: `true` if max attempts reached, `false` otherwise (or if no limit)
    func hasReachedMaxAttempts(_ currentAttemptCount: UInt) -> Bool {
        guard let maxAttempts else {
            return false
        }
        return currentAttemptCount >= maxAttempts
    }
}
