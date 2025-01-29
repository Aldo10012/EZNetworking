import Foundation

public enum HTTPSuccessStatus: Int, Error {
    case ok = 200
    case created = 201
    case accepted = 202
    case nonAuthoritativeInformation = 203
    case noContent = 204
    case resetContent = 205
    case partialContent = 206
    case multiStatus = 207
    case alreadyReported = 208
    case iMUsed = 226
    case unknown = -1
    
    public init(statusCode: Int) {
        if let error = HTTPSuccessStatus(rawValue: statusCode) {
            self = error
        } else {
            self = .unknown
        }
    }
    
    public var description: String { return "\(self)" }
    public var statusCode: Int { return self.rawValue }
}
