import Foundation

public protocol Uploadable: Actor {
    /// Starts the upload and returns a stream of events
    func upload() -> AsyncStream<UploadEvent>

    /// Pauses the active upload
    func pause() async throws

    /// Resumes a paused upload
    func resume() async throws

    /// Cancels the upload
    func cancel() async throws
}
