import Foundation
import Network

public actor NetworkMonitor: NetworkReachability {
    // MARK: - Internal State
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: NetworkConnectionType = .unknown
    private(set) var isExpensive: Bool = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "EZNetworking.NetworkMonitor")

    // Use a stream continuation to multicast updates if needed,
    // but for simplicity, we'll stick to a fresh stream per caller.
    private var isRunning = false

    // MARK: - Lifecycle

    public func startMonitoring() {
        guard !isRunning else { return }
        isRunning = true

        monitor.pathUpdateHandler = { [weak self] path in
            Task { [weak self] in
                await self?.handlePathUpdate(path)
            }
        }
        monitor.start(queue: queue)
    }

    public func stopMonitoring() {
        isRunning = false
        monitor.cancel()
    }

    // MARK: - Observation

    public nonisolated func statusUpdates() -> AsyncStream<NetworkStatus> {
        AsyncStream { continuation in
            // Capture the current state immediately upon subscription
            Task {
                let initialStatus = await self.getCurrentStatus()
                continuation.yield(initialStatus)
            }

            // We wrap the pathUpdateHandler to also yield to this specific continuation
            let observerMonitor = NWPathMonitor()
            observerMonitor.pathUpdateHandler = { path in
                let status = NetworkStatus(
                    isConnected: path.status == .satisfied,
                    connectionType: NetworkConnectionType(from: path),
                    isExpensive: path.isExpensive
                )
                continuation.yield(status)
            }

            observerMonitor.start(queue: queue)

            continuation.onTermination = { _ in
                observerMonitor.cancel()
            }
        }
    }

    private func handlePathUpdate(_ path: NWPath) {
        self.isConnected = path.status == .satisfied
        self.isExpensive = path.isExpensive
        self.connectionType = NetworkConnectionType(from: path)
    }

    private func getCurrentStatus() -> NetworkStatus {
        NetworkStatus(isConnected: isConnected, connectionType: connectionType, isExpensive: isExpensive)
    }
}
