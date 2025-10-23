import Foundation

public typealias HTTPBody = Data

public protocol DataConvertible {
    func toData() -> Data?
}

extension Data: DataConvertible {
    public func toData() -> Data? { self }
}
