import Foundation

public enum DownloadEvent: Sendable, Equatable {
    case progress(Double)
    case completed(URL)
    case failed(NetworkingError)

    public static func == (lhs: DownloadEvent, rhs: DownloadEvent) -> Bool {
        switch (lhs, rhs) {
        case let (.progress(lhsP), .progress(rhsP)):
            lhsP == rhsP
        case let (.completed(lhsURL), .completed(rhsURL)):
            lhsURL == rhsURL
        case let (.failed(lhsE), .failed(rhsE)):
            lhsE == rhsE
        default:
            false
        }
    }
}
