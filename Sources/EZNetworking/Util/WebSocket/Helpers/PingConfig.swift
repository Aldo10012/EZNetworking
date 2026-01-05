import Foundation

public struct PingConfig {
    public let pingInterval: Duration
    public let maxPingFailures: UInt
    
    public init(pingInterval: Duration = Duration.seconds(30), maxPingFailures: UInt = 3) {
        self.pingInterval = pingInterval
        
        if maxPingFailures == 0 {
            self.maxPingFailures = 1
        } else {
            self.maxPingFailures = maxPingFailures
        }
    }
    
    internal func waitForPingInterval() async {
        try? await Task.sleep(for: pingInterval)
    }
}
