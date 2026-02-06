import Foundation

public enum InternalError: Error {
    case requestFailed(Error)
}

extension InternalError: Equatable {
    public static func == (lhs: InternalError, rhs: InternalError) -> Bool {
        switch (lhs, rhs) {
        case let (.requestFailed(lhsError), .requestFailed(rhsError)):
            (lhsError as NSError) == (rhsError as NSError)
        }
    }
}
