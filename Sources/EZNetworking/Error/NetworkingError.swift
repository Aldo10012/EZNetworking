import Foundation

public enum NetworkingError: Error, Sendable {
    case couldNotBuildURLRequest(reason: URLBuildFailureReason)
    case decodingFailed(reason: DecodingFailureReason)
    case responseValidationFailed(reason: ResponseValidationFailureReason)
    case requestFailed(reason: RequestFailureReason)
    case webSocketFailed(reason: WebSocketFailureReason)
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

        case let (.webSocketFailed(reason: reason1), .webSocketFailed(reason: reason2)):
            reason1 == reason2

        default:
            false
        }
    }
}
