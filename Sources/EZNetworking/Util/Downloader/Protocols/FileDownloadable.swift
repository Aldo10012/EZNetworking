import Foundation

public protocol FileDownloadable: Actor {
    /// Starts the download and returns a stream of events
    func downloadFileStream() -> AsyncStream<DownloadEvent>

    /// Pauses the active download
    func pause() async

    /// Resumes a paused download
    func resume() async

    /// Cancels the download
    func cancel()
}

public enum DownloadEvent: Sendable {
    case started
    case progress(Double)
    case paused
    case resumed
    case completed(URL)
    case failed(NetworkingError)
    case cancelled
}
