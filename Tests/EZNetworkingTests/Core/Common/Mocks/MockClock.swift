import Foundation

/// A `Clock` test double that records requested sleep durations and resumes instantly,
/// so tests can assert on backoff timing without waiting on real wall-clock time.
final class MockClock: Clock, @unchecked Sendable {
    struct Instant: InstantProtocol {
        var offset: Duration

        static func < (lhs: Instant, rhs: Instant) -> Bool {
            lhs.offset < rhs.offset
        }

        func advanced(by duration: Duration) -> Instant {
            Instant(offset: offset + duration)
        }

        func duration(to other: Instant) -> Duration {
            other.offset - offset
        }
    }

    private(set) var sleptDurations: [Duration] = []

    var now = Instant(offset: .zero)
    var minimumResolution: Duration = .zero

    func sleep(until deadline: Instant, tolerance: Duration? = nil) async throws {
        try Task.checkCancellation()
        sleptDurations.append(now.duration(to: deadline))
        // `Task.checkCancellation()` and the array append above never suspend, so without an
        // explicit yield this "sleep" never hands control back to the scheduler. Ping-style loops
        // that call this in a tight cycle would then monopolize their actor's executor forever,
        // starving cancellation and any other work on that actor.
        await Task.yield()
    }
}
