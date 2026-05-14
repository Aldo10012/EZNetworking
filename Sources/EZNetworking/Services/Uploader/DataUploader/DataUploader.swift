import Foundation

public actor DataUploader: Uploadable {
    public func upload() -> AsyncStream<UploadEvent> {
        // swiftlint:disable:next todo
        // TODO: implement
        AsyncStream<UploadEvent> { $0.finish() }
    }

    public func pause() async throws {
        // swiftlint:disable:next todo
        // TODO: implement
    }

    public func resume() async throws {
        // swiftlint:disable:next todo
        // TODO: implement
    }

    public func cancel() throws {
        // swiftlint:disable:next todo
        // TODO: implement
    }
}
