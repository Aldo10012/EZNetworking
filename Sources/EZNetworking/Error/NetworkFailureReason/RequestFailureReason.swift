import Foundation

public enum RequestFailureReason: Equatable, Sendable {
    case urlError(underlying: URLError)
    case unknownError(underlying: SendableError)

    public static func == (lhs: RequestFailureReason, rhs: RequestFailureReason) -> Bool {
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
