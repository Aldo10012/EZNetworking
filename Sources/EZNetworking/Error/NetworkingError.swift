import Foundation

public enum NetworkingError: Error {
    case internalError(InternalError)     /// any internal error
    case httpError(HTTPError)             /// any HRRP error
    case urlError(URLError)               /// any URL error
}

extension NetworkingError: Equatable {
    public static func ==(lhs: NetworkingError, rhs: NetworkingError) -> Bool {
        switch (lhs, rhs) {
        case let (.internalError(error1), .internalError(error2)):
            return error1 == error2

        case let (.httpError(error1), .httpError(error2)):
            return error1.statusCode == error2.statusCode

        case let (.urlError(error), .urlError(error2)):
            return error == error2

        default:
            return false
        }
    }
}
