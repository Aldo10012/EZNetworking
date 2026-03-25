import Foundation

public protocol FileUploadable: Actor {
    /// Starts the upload and returns a stream of events
    func uploadFileStream() -> AsyncStream<UploadEvent>

    /// Pauses the active upload
    func pause() async throws

    /// Resumes a paused upload
    func resume() async throws

    /// Cancels the upload
    func cancel() throws
}
