import Foundation
import Network

public enum NetworkConnectionType: Sendable, Equatable {
    case wifi
    case cellular
    case wired
    case unknown

    init(from path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            self = .wifi
        } else if path.usesInterfaceType(.cellular) {
            self = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            self = .wired
        } else {
            self = .unknown
        }
    }
}
