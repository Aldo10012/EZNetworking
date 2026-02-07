import Foundation

public enum NetworkingError: Error {
    case couldNotBuildURLRequest(reason: URLBuildFailureReason)
    case decodingFailed(reason: DecodingFailureReason)
    case responseValidationFailed(reason: ResponseValidationFailureReason)
    case requestFailed(reason: RequestFailureReason)

    case internalError(InternalError) /// any internal error
    case urlError(URLError) /// any URL error
}

extension NetworkingError: Equatable {
    public static func == (lhs: NetworkingError, rhs: NetworkingError) -> Bool {
        switch (lhs, rhs) {
        case let (.couldNotBuildURLRequest(reason: reason1), .couldNotBuildURLRequest(reason: reason2)):
            reason1 == reason2

        case let (.decodingFailed(reason: reason1), .decodingFailed(reason: reason2)):
            reason1 == reason2

        case let (.responseValidationFailed(reason: reason1), .responseValidationFailed(reason: reason2)):
            reason1 == reason2

        case let (.requestFailed(reason: reason1), .requestFailed(reason: reason2)):
            reason1 == reason2

        case let (.internalError(error1), .internalError(error2)):
            error1 == error2

        case let (.urlError(error), .urlError(error2)):
            error == error2

        default:
            false
        }
    }
}
