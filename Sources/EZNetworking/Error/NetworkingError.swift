import Foundation

public enum NetworkingError: Error {
    case couldNotBuildURLRequest(reason: URLBuildFailureReason)
    case decodingFailed(reason: DecodingFailureReason)
    case responseValidationFailed(reason: ResponseValidationFailureReason)
    case requestFailedReason(reason: RequestFailedReason)

    case internalError(InternalError) /// any internal error
    case urlError(URLError) /// any URL error
}

extension NetworkingError: Equatable {
    public static func == (lhs: NetworkingError, rhs: NetworkingError) -> Bool {
        switch (lhs, rhs) {
        case let (.couldNotBuildURLRequest(reason: error1), .couldNotBuildURLRequest(reason: error2)):
            error1 == error2

        case let (.internalError(error1), .internalError(error2)):
            error1 == error2

        case let (.urlError(error), .urlError(error2)):
            error == error2

        default:
            false
        }
    }
}
