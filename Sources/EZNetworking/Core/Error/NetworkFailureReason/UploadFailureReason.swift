import Foundation

public enum UploadFailureReason: Equatable, Sendable {
    // state related errors
    case cannotResume
    case alreadyUploading
    case alreadyFinished
    case uploadIncompleteButResumable
    case notUploading
    case notPaused

    // network related errors
    case urlError(underlying: URLError)
    case unknownError(underlying: SendableError)
    case failedButResumable(underlying: SendableError)

    public static func == (lhs: UploadFailureReason, rhs: UploadFailureReason) -> Bool {
        switch (lhs, rhs) {
        case let (.urlError(underlying: lhsError), .urlError(underlying: rhsError)):
            (lhsError as NSError) == (rhsError as NSError)
        case (.cannotResume, .cannotResume),
             (.alreadyUploading, .alreadyUploading),
             (.alreadyFinished, .alreadyFinished),
             (.uploadIncompleteButResumable, .uploadIncompleteButResumable),
             (.notUploading, .notUploading),
             (.notPaused, .notPaused):
            true
        case let (.unknownError(underlying: lhsError), .unknownError(underlying: rhsError)):
            (lhsError as NSError) == (rhsError as NSError)
        case let (.failedButResumable(underlying: lhsError), .failedButResumable(underlying: rhsError)):
            (lhsError as NSError) == (rhsError as NSError)
        default:
            false
        }
    }
}
