import Foundation
import Testing

final class Expectation: Sendable {
    private let continuation: AsyncStream<Void>.Continuation
    private let stream: AsyncStream<Void>
    private let expectedFulfillmentCount: Int
    private let isInverted: Bool

    /// Creates a new expectation.
    ///
    /// - Parameters:
    ///   - expectedFulfillmentCount: The number of times `fulfill()` must be called. Default is 1.
    ///   - isInverted: If true, the expectation fails if fulfilled. Default is false.
    init(expectedFulfillmentCount: Int = 1, isInverted: Bool = false) {
        precondition(expectedFulfillmentCount > 0, "expectedFulfillmentCount must be greater than 0")

        self.expectedFulfillmentCount = expectedFulfillmentCount
        self.isInverted = isInverted

        var continuation: AsyncStream<Void>.Continuation!
        self.stream = AsyncStream<Void> { cont in
            continuation = cont
        }
        self.continuation = continuation
    }

    /// Marks the expectation as fulfilled.
    ///
    /// Call this method when the asynchronous operation you're testing completes.
    /// If `expectedFulfillmentCount` is greater than 1, you must call this method
    /// that many times for the expectation to be considered fulfilled.
    func fulfill() {
        continuation.yield()
    }

    /// Waits for the expectation to be fulfilled within the specified timeout.
    ///
    /// - Parameter timeout: The maximum time to wait for fulfillment.
    /// - Throws: If the expectation is not fulfilled within the timeout period.
    func fulfillment(within timeout: Duration) async {
        let timeoutTask = Task {
            try? await Task.sleep(for: timeout)
        }

        let fulfillmentTask = Task {
            var count = 0
            for await _ in stream {
                count += 1
                if count >= expectedFulfillmentCount {
                    break
                }
            }
            return count
        }

        let result = await fulfillmentTask.value
        timeoutTask.cancel()

        if isInverted {
            if result >= expectedFulfillmentCount {
                Issue.record("Inverted expectation was fulfilled")
            }
        } else {
            if result < expectedFulfillmentCount {
                Issue.record("Expectation was not fulfilled within \(timeout). Fulfilled \(result)/\(expectedFulfillmentCount) times.")
            }
        }
    }
}
