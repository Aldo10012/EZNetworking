import Foundation

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

