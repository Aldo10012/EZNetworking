import Foundation

public typealias SendableError = Error & Sendable

/// A thread-safe wrapper for Error types that may not conform to Sendable.
public struct SendableErrorWrapper: Error, CustomNSError, Sendable {
    public let localizedDescription: String
    public let domain: String
    public let code: Int

    public init(_ error: Error) {
        let nsError = error as NSError
        self.localizedDescription = nsError.localizedDescription
        self.domain = nsError.domain
        self.code = nsError.code
    }

    public static var errorDomain: String { "EZNetworking.SendableErrorWrapper" }
    public var errorCode: Int { code }
    public var errorUserInfo: [String: Any] {
        [NSLocalizedDescriptionKey: localizedDescription, "wrappedDomain": domain]
    }
}

extension Error {
    public var asSendableError: SendableError {
        if let sendableErrorWrapper = self as? SendableErrorWrapper {
            return sendableErrorWrapper
        }
        if let sendable = self as? SendableError {
            return sendable
        }
        if Mirror(reflecting: self).displayStyle == .class {
            return SendableErrorWrapper(self)
        }
        return SendableErrorWrapper(self)
    }
}
