import Foundation

public enum RequestFailedReason: Equatable, Sendable {
    case urlError(underlying: URLError)
    case unknownError(underlying: Error)

    public static func == (lhs: RequestFailedReason, rhs: RequestFailedReason) -> Bool {
        switch (lhs, rhs) {
        case let (.urlError(underlying: L), .urlError(underlying: R)):
            (L as NSError) == (R as NSError)
        case let (.unknownError(underlying: L), .unknownError(underlying: R)):
            (L as NSError) == (R as NSError)
        default:
            false
        }
    }
}
