import Foundation

public enum DecodingFailureReason: Equatable, Sendable {
    case decodingError(underlying: DecodingError)
    case other(underlying: SendableError)

    public static func == (lhs: DecodingFailureReason, rhs: DecodingFailureReason) -> Bool {
        switch (lhs, rhs) {
        case let (.decodingError(underlying: L), .decodingError(underlying: R)):
            (L as NSError) == (R as NSError)
        case let (.other(underlying: L), .other(underlying: R)):
            (L as NSError) == (R as NSError)
        default:
            false
        }
    }
}
