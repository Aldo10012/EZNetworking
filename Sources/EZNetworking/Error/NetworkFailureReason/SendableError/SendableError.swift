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
        if let wrapper = self as? SendableErrorWrapper {
            return wrapper
        }
        let mirror = Mirror(reflecting: self)
        if mirror.displayStyle == .class {
            return SendableErrorWrapper(self)
        }
        if let sendable = self as? SendableError {
            return sendable
        }
        return SendableErrorWrapper(self)
    }
}
