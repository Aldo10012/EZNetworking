import Foundation

/// Configuration for automatic reconnection behavior, including strategy and retry limits for SSE connections.
public struct RetryPolicy: Sendable {
    /// Determines if the client should automatically attempt to reconnect after unexpected stream errors.
    internal let enabled: Bool
    /// The maximum number of retry attempts; set to nil for unlimited attempts.
    public let maxAttempts: UInt?
    /// The starting delay in seconds for the first reconnection attempt.
    public let initialDelay: TimeInterval
    /// The upper limit in seconds for the delay between reconnection attempts.
    public let maxDelay: TimeInterval
    /// The multiplier used to calculate exponential backoff for subsequent retries.
    public let backoffMultiplier: Double
    /// The clock used to schedule reconnection delays; injectable for deterministic testing.
    private let clock: any Clock<Duration>

    /// Initializes a new configuration with specific reconnection and backoff parameters.
    public init(
        maxAttempts: UInt? = nil,
        initialDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 60.0,
        backoffMultiplier: Double = 2.0
    ) {
        self.init(
            enabled: true,
            maxAttempts: maxAttempts,
            initialDelay: initialDelay,
            maxDelay: maxDelay,
            backoffMultiplier: backoffMultiplier,
            clock: ContinuousClock()
        )
    }

    /// Initializes a new configuration with specific reconnection and backoff parameters.
    internal init(
        enabled: Bool = true,
        maxAttempts: UInt? = nil,
        initialDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 60.0,
        backoffMultiplier: Double = 2.0,
        clock: any Clock<Duration> = ContinuousClock()
    ) {
        self.enabled = enabled
        self.maxAttempts = maxAttempts
        self.initialDelay = initialDelay
        self.maxDelay = maxDelay
        self.backoffMultiplier = backoffMultiplier
        self.clock = clock
    }
}

extension RetryPolicy {
    /// Suspends the current task for the backoff delay calculated for the given attempt.
    ///
    /// Combines `calculateDelay(for:)` with an async sleep, allowing callers to pause
    /// between retry attempts without managing the delay arithmetic themselves.
    /// Throws `CancellationError` if the task is cancelled; callers can use `try?` for silent handling.
    ///
    /// The `clock` parameter defaults to `ContinuousClock` in production, but can be swapped
    /// for a test double so unit tests don't need to wait on real wall-clock time.
    ///
    /// - Parameters:
    ///   - attemptCount: The current attempt number (1-indexed) used to derive the delay.
    ///   - clock: The clock used to perform the suspension. Defaults to `ContinuousClock()`.
    func sleep(forAttempt attemptCount: UInt) async throws {
        let delay = calculateDelay(for: attemptCount)
        try await clock.sleep(for: .seconds(delay))
    }

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

extension RetryPolicy {
    public static var none: RetryPolicy {
        RetryPolicy(enabled: false, maxAttempts: nil, initialDelay: 0, maxDelay: 0, backoffMultiplier: 0)
    }
}
