@testable import EZNetworking
import Foundation
import Testing

@Suite("Test RetryPolicy")
struct RetryPolicyTests {
    @Test("test Default values are correctly assigned")
    func defaultValues() {
        let config = RetryPolicy()

        #expect(config.enabled == true)
        #expect(config.maxAttempts == nil)
        #expect(config.initialDelay == 1.0)
        #expect(config.maxDelay == 60.0)
        #expect(config.backoffMultiplier == 2.0)
    }

    @Test("test Custom initialization values are correctly assigned")
    func customValues() {
        let config = RetryPolicy(
            enabled: false,
            maxAttempts: 5,
            initialDelay: 2.5,
            maxDelay: 30.0,
            backoffMultiplier: 1.5
        )

        #expect(config.enabled == false)
        #expect(config.maxAttempts == 5)
        #expect(config.initialDelay == 2.5)
        #expect(config.maxDelay == 30.0)
        #expect(config.backoffMultiplier == 1.5)
    }

    @Test("test Exponential backoff logic calculation")
    func backoffCalculation() {
        let config = RetryPolicy(initialDelay: 2.0, maxDelay: 10.0, backoffMultiplier: 2.0)

        // Manual calculation of: min(initialDelay * pow(backoffMultiplier, attempt), maxDelay)
        // Attempt 0: 2.0 * 2^0 = 2.0
        // Attempt 1: 2.0 * 2^1 = 4.0
        // Attempt 2: 2.0 * 2^2 = 8.0
        // Attempt 3: 2.0 * 2^3 = 16.0 -> capped at 10.0

        func calculateDelay(attempt: Int) -> Double {
            min(config.initialDelay * pow(config.backoffMultiplier, Double(attempt)), config.maxDelay)
        }

        #expect(calculateDelay(attempt: 0) == 2.0)
        #expect(calculateDelay(attempt: 1) == 4.0)
        #expect(calculateDelay(attempt: 2) == 8.0)
        #expect(calculateDelay(attempt: 3) == 10.0)
    }

    @Test("test Max attempts boundary", arguments: [1, 10, 100])
    func maxAttemptsBoundaries(attempts: UInt) {
        let config = RetryPolicy(maxAttempts: attempts)
        #expect(config.maxAttempts == attempts)
    }

    // MARK: - Delay Calculation Tests

    @Test("test Delay calculation follows exponential backoff", arguments: [
        (1, 1.0), // 1.0 * 2^0 = 1.0
        (2, 2.0), // 1.0 * 2^1 = 2.0
        (3, 4.0), // 1.0 * 2^2 = 4.0
        (4, 8.0), // 1.0 * 2^3 = 8.0
        (10, 60.0) // Capped at maxDelay
    ])
    func testCalculateDelay(attempt: UInt, expectedDelay: TimeInterval) {
        let config = RetryPolicy(initialDelay: 1.0, maxDelay: 60.0, backoffMultiplier: 2.0)

        let result = config.calculateDelay(for: attempt)
        #expect(result == expectedDelay)
    }

    @Test("test Delay calculation returns 0 for invalid attempt (0)")
    func calculateDelayZero() {
        let config = RetryPolicy()
        #expect(config.calculateDelay(for: 0) == 0)
    }

    // MARK: - Max Attempts Tests

    @Test("test Max attempts logic with limit set", arguments: [
        (3, 2, false), // 2 < 3: Proceed
        (3, 3, true), // 3 == 3: Reached
        (3, 4, true) // 4 > 3: Reached
    ])
    func testHasReachedMaxAttempts(limit: UInt, current: UInt, expected: Bool) {
        let config = RetryPolicy(maxAttempts: limit)
        #expect(config.hasReachedMaxAttempts(current) == expected)
    }

    @Test("test Max attempts logic with no limit (nil)")
    func hasReachedMaxAttemptsUnlimited() {
        let config = RetryPolicy(maxAttempts: nil)

        #expect(config.hasReachedMaxAttempts(0) == false)
        #expect(config.hasReachedMaxAttempts(999) == false)
        #expect(config.hasReachedMaxAttempts(UInt.max) == false)
    }
}
