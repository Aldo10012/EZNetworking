import Foundation

public struct PingConfig: Sendable {
    public let pingInterval: Duration
    public let maxPingFailures: UInt
    /// The clock used to schedule the wait between pings; injectable for deterministic testing.
    private let clock: any Clock<Duration>

    public init(pingInterval: Duration = Duration.seconds(30), maxPingFailures: UInt = 3) {
        self.init(pingInterval: pingInterval, maxPingFailures: maxPingFailures, clock: ContinuousClock())
    }

    internal init(
        pingInterval: Duration = Duration.seconds(30),
        maxPingFailures: UInt = 3,
        clock: any Clock<Duration> = ContinuousClock()
    ) {
        self.pingInterval = pingInterval

        if maxPingFailures == 0 {
            self.maxPingFailures = 1
        } else {
            self.maxPingFailures = maxPingFailures
        }
        self.clock = clock
    }

    func waitForPingInterval() async {
        try? await clock.sleep(for: pingInterval)
    }
}
