import Foundation

public struct PingConfig {
    public let pingInterval: IntervalDuration
    public let maxPingFailures: UInt

    public init(pingInterval: IntervalDuration = IntervalDuration.seconds(30), maxPingFailures: UInt = 3) {
        self.pingInterval = pingInterval

        if maxPingFailures == 0 {
            self.maxPingFailures = 1
        } else {
            self.maxPingFailures = maxPingFailures
        }
    }

    func waitForPingInterval() async {
        if #available(iOS 16.0, *) {
            switch pingInterval {
            case let .nanoseconds(nanoseconds):
                try? await Task.sleep(for: .nanoseconds(nanoseconds))
            case let .milliseconds(milliseconds):
                try? await Task.sleep(for: .milliseconds(milliseconds))
            case let .seconds(seconds):
                try? await Task.sleep(for: .seconds(seconds))
            }
        } else {
            // Fallback on earlier versions
            switch pingInterval {
            case let .nanoseconds(nanoseconds):
                try? await Task.sleep(nanoseconds: nanoseconds)
            case let .milliseconds(milliseconds):
                try? await Task.sleep(nanoseconds: milliseconds * 1_000_000)
            case let .seconds(seconds):
                try? await Task.sleep(nanoseconds: seconds * 1_000_000_000)
            }
        }
    }
}

public enum IntervalDuration: Equatable {
    case nanoseconds(_ nanoseconds: UInt64)
    case milliseconds(_ milliseconds: UInt64)
    case seconds(_ seconds: UInt64)

    public static func == (lhs: IntervalDuration, rhs: IntervalDuration) -> Bool {
        switch (lhs, rhs) {
        case let (.nanoseconds(lT), .nanoseconds(rT)),
             let (.milliseconds(lT), .milliseconds(rT)),
             let (.seconds(lT), .seconds(rT)):
            lT == rT
        default:
            false
        }
    }
}
