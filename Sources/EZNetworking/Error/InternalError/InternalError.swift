import Foundation

public enum InternalError: Equatable, Sendable {
    case requestFailed(Error)

    public static func == (lhs: InternalError, rhs: InternalError) -> Bool {
        switch (lhs, rhs) {
        case let (.requestFailed(lhsError), .requestFailed(rhsError)):
            (lhsError as NSError) == (rhsError as NSError)
        }
    }
}
