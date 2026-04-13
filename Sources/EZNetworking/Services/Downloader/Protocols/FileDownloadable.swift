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
