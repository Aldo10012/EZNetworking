import Foundation
import Network

public protocol NetworkReachability: Actor {
    var isConnected: Bool { get async }
    var connectionType: NetworkConnectionType { get async }

    func startMonitoring()
    func stopMonitoring()
    func statusUpdates() -> AsyncStream<NetworkStatus>
}
