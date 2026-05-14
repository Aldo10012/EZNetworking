import Foundation

public actor FileUploader: Uploadable {
    public func upload() -> AsyncStream<UploadEvent> {
        fatalError("TODO: implement")
    }
    
    public func pause() async throws {
        // TODO: implement
    }
    
    public func resume() async throws {
        // TODO: implement
    }
    
    public func cancel() throws {
        // TODO: implement
    }
}
