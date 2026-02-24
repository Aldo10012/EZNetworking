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

public typealias SendableError = Error & Sendable

/// A thread-safe wrapper for Error types that may not conform to Sendable.
public struct SendableErrorWrapper: Error, Sendable {
    public let localizedDescription: String
    public let domain: String
    public let code: Int

    public init(_ error: Error) {
        let nsError = error as NSError
        self.localizedDescription = nsError.localizedDescription
        self.domain = nsError.domain
        self.code = nsError.code
    }
}

extension Error {
    var asSendableError: SendableError {
        if let sendable = self as? SendableError {
            return sendable
        }
        return SendableErrorWrapper(self)
    }
}
