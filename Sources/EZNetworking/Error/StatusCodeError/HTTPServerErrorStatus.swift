import Foundation

public enum HTTPServerErrorStatus: Int, Error {
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    case httpVersionNotSupported = 505
    case variantAlsoNegotiates = 506
    case insufficientStorage = 507
    case loopDetected = 508
    case notExtended = 510
    case networkAuthenticationRequired = 511
    case unknown = -1

    public init(statusCode: Int) {
        if let error = HTTPServerErrorStatus(rawValue: statusCode) {
            self = error
        } else {
            self = .unknown
        }
    }
}
