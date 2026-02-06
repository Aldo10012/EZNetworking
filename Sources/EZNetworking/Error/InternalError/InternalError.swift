import Foundation

// TODO: move to another file
public enum URLBuildFailureReason: Equatable, Sendable {
    case noURL
    case invalidURL
    case invalidScheme(String?)
    case missingHost
}

public enum InternalError: Error {
    case couldNotParse(underlying: Error)
    case requestFailed(Error)
    case noHTTPURLResponse
}

extension InternalError: Equatable {
    public static func == (lhs: InternalError, rhs: InternalError) -> Bool {
        switch (lhs, rhs) {
        case (.noHTTPURLResponse, .noHTTPURLResponse):
            true

        case let (.requestFailed(lhsError), .requestFailed(rhsError)),
             let (.couldNotParse(underlying: lhsError), .couldNotParse(underlying: rhsError)):
            (lhsError as NSError) == (rhsError as NSError)

        default:
            false
        }
    }
}
