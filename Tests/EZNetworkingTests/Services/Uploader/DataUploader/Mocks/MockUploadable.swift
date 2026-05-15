import EZNetworking
import Foundation

actor MockUploadable: Uploadable {
    private(set) var uploadCallCount = 0
    private(set) var pauseCallCount = 0
    private(set) var resumeCallCount = 0
    private(set) var cancelCallCount = 0

    private var pauseError: Error?
    private var resumeError: Error?
    private var cancelError: Error?

    private var pendingStream: AsyncStream<UploadEvent>?
    private var continuation: AsyncStream<UploadEvent>.Continuation?

    init() {
        let (stream, continuation) = AsyncStream<UploadEvent>.makeStream()
        self.pendingStream = stream
        self.continuation = continuation
    }

    func setPauseError(_ error: Error?) { pauseError = error }
    func setResumeError(_ error: Error?) { resumeError = error }
    func setCancelError(_ error: Error?) { cancelError = error }

    func upload() -> AsyncStream<UploadEvent> {
        uploadCallCount += 1
        let stream = pendingStream ?? AsyncStream { $0.finish() }
        pendingStream = nil
        return stream
    }

    func pause() async throws {
        pauseCallCount += 1
        if let pauseError { throw pauseError }
    }

    func resume() async throws {
        resumeCallCount += 1
        if let resumeError { throw resumeError }
    }

    func cancel() throws {
        cancelCallCount += 1
        if let cancelError { throw cancelError }
        continuation?.finish()
        continuation = nil
    }

    func emit(_ event: UploadEvent) {
        continuation?.yield(event)
    }

    func finishStream() {
        continuation?.finish()
        continuation = nil
    }
}
