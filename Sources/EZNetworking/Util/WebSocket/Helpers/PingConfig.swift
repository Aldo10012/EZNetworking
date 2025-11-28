import Foundation

public struct PingConfig {
    let pingInterval: UInt64
    let maxPingFailures: Int
    
    public init(pingInterval: UInt64 = 30, maxPingFailures: Int = 3) {
        self.pingInterval = pingInterval
        self.maxPingFailures = maxPingFailures
    }
}
