import Foundation

public typealias HTTPBody = DataConvertible

public protocol DataConvertible {
    func toData() -> Data?
}

extension Data: DataConvertible {
    public func toData() -> Data? { self }
}
