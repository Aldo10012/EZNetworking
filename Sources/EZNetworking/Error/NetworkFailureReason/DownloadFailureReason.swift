import Foundation

public enum DownloadFailureReason: Equatable, Sendable {
    case urlError(underlying: URLError)
    case invalidResponse
    case cannotResume
    case alreadyDownloading
    case notDownloading
    case notPaused
    case unknownError(underlying: SendableError)

    public static func == (lhs: DownloadFailureReason, rhs: DownloadFailureReason) -> Bool {
        switch (lhs, rhs) {
        case let (.urlError(underlying: lhsError), .urlError(underlying: rhsError)):
            (lhsError as NSError) == (rhsError as NSError)
        case (.invalidResponse, .invalidResponse),
             (.cannotResume, .cannotResume),
             (.alreadyDownloading, .alreadyDownloading),
             (.notDownloading, .notDownloading),
             (.notPaused, .notPaused):
            true
        case let (.unknownError(underlying: lhsError), .unknownError(underlying: rhsError)):
            (lhsError as NSError) == (rhsError as NSError)
        default:
            false
        }
    }
}
