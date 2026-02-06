import Foundation

public enum InternalError: Error {
    // URL error
    case noURL
    case invalidURL
    case invalidScheme(String?)

    case couldNotParse(underlying: Error)
    case requestFailed(Error)
    case noHTTPURLResponse
}

extension InternalError: Equatable {
    public static func == (lhs: InternalError, rhs: InternalError) -> Bool {
        switch (lhs, rhs) {
        case (.noURL, .noURL),
             (.invalidURL, .invalidURL),
             (.noHTTPURLResponse, .noHTTPURLResponse):
            true

        case let (.requestFailed(lhsError), .requestFailed(rhsError)),
             let (.couldNotParse(underlying: lhsError), .couldNotParse(underlying: rhsError)):
            (lhsError as NSError) == (rhsError as NSError)

        case let (.invalidScheme(lhsScheme), .invalidScheme(rhsScheme)):
            lhsScheme == rhsScheme

        default:
            false
        }
    }
}
