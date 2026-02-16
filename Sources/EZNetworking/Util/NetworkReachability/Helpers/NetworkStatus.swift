import Foundation

public struct NetworkStatus: Sendable, Equatable {
    let isConnected: Bool
    let connectionType: NetworkConnectionType
    let isExpensive: Bool
}
