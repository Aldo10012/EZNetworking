import Foundation

public protocol FileDownloadable: Actor {
    /// Starts the download and returns a stream of events
    func downloadFileStream() -> AsyncStream<DownloadEvent>

    /// Pauses the active download
    func pause() async throws

    /// Resumes a paused download
    func resume() async throws

    /// Cancels the download
    func cancel() throws
}

public enum DownloadEvent: Sendable, Equatable {
    case started
    case progress(Double)
    case paused
    case resumed
    case completed(URL)
    case failed(NetworkingError)
    case cancelled

    public static func == (lhs: DownloadEvent, rhs: DownloadEvent) -> Bool {
        switch (lhs, rhs) {
        case (.started, .started), (.paused, .paused), (.resumed, .resumed), (.cancelled, .cancelled):
            true
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
