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

    internal func waitForPingInterval() async {
        if #available(iOS 16.0, *) {
            switch pingInterval {
            case .nanoseconds(let nanoseconds):
                try? await Task.sleep(for: .nanoseconds(nanoseconds))
            case .milliseconds(let milliseconds):
                try? await Task.sleep(for: .milliseconds(milliseconds))
            case .seconds(let seconds):
                try? await Task.sleep(for: .seconds(seconds))
            }
        } else {
            // Fallback on earlier versions
            switch pingInterval {
            case .nanoseconds(let nanoseconds):
                try? await Task.sleep(nanoseconds: nanoseconds)
            case .milliseconds(let milliseconds):
                try? await Task.sleep(nanoseconds: milliseconds * 1_000_000)
            case .seconds(let seconds):
                try? await Task.sleep(nanoseconds: seconds * 1_000_000_000)
            }
        }
    }
}

public enum IntervalDuration: Equatable {
    case nanoseconds(_ nanoseconds: UInt64)
    case milliseconds(_ milliseconds: UInt64)
    case seconds(_ seconds: UInt64)

    public static func ==(lhs: IntervalDuration, rhs: IntervalDuration) -> Bool {
        switch (lhs, rhs) {
        case (.nanoseconds(let lT), .nanoseconds(let rT)),
            (.milliseconds(let lT), .milliseconds(let rT)),
            (.seconds(let lT), .seconds(let rT)):
            return lT == rT
        default:
            return false
        }
    }
}
