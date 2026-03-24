import Foundation

public protocol FileUploadable: Actor {
    /// Starts the upload and returns a stream of events
    func uploadFileStream() -> AsyncStream<UploadEvent>

    /// Pauses the active upload
    @available(iOS 17.0, macOS 14.0, *)
    func pause() async throws

    /// Resumes a paused upload
    @available(iOS 17.0, macOS 14.0, *)
    func resume() async throws

    /// Cancels the upload
    func cancel() throws
}
