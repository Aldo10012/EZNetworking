import Foundation

public actor ResumableDownloader: ResumableDownloadable {
    private let serverUrl: URL
    private let session: NetworkSession
    private let validator: ResponseValidator

    private var activeTask: URLSessionDownloadTaskProtocol?
    private var resumeData: Data?
    private var continuation: AsyncStream<DownloadEvent>.Continuation?
    private var state: DownloadState = .idle
    private var activeInterceptor: DownloadTaskInterceptor?

    private enum DownloadState {
        case idle
        case downloading
        case paused
        case completed
        case cancelled
    }

    // MARK: init

    public init(
        from serverUrl: URL,
        session: NetworkSession = Session(),
        validator: ResponseValidator = DefaultResponseValidator()
    ) {
        self.serverUrl = serverUrl
        self.session = session
        self.validator = validator
    }

    // MARK: - downloadFileStream

    public func downloadFileStream() -> AsyncStream<DownloadEvent> {
        let (stream, continuation) = AsyncStream<DownloadEvent>.makeStream()
        self.continuation = continuation
        state = .downloading
        continuation.yield(.started)

        startDownload(with: continuation)

        return stream
    }

    // MARK: - pause

    public func pause() async {
        guard state == .downloading, let task = activeTask else { return }
        state = .paused
        resumeData = await task.cancelByProducingResumeData()
        activeTask = nil
        continuation?.yield(.paused)
    }

    // MARK: - resume

    public func resume() async {
        guard state == .paused else { return }
        guard let continuation else { return }
        state = .downloading
        continuation.yield(.resumed)

        startDownload(with: continuation)
    }

    // MARK: - cancel

    public func cancel() {
        guard state == .downloading || state == .paused else { return }
        state = .cancelled
        activeTask?.cancel()
        activeTask = nil
        resumeData = nil
        continuation?.yield(.cancelled)
        continuation?.finish()
        continuation = nil
    }

    // MARK: - Helpers

    private func startDownload(with continuation: AsyncStream<DownloadEvent>.Continuation) {
        let interceptor = ResumableDownloadTaskInterceptor(continuation: continuation) { [weak self] in
            await self?.markCompleted()
        }
        activeInterceptor = interceptor
        session.delegate.downloadTaskInterceptor = interceptor

        let task: URLSessionDownloadTaskProtocol
        if let resumeData {
            self.resumeData = nil
            task = session.urlSession.downloadTask(withResumeData: resumeData)
        } else {
            task = session.urlSession.downloadTask(with: URLRequest(url: serverUrl))
        }
        activeTask = task
        task.resume()
    }

    private func markCompleted() {
        guard state == .downloading else { return }
        state = .completed
        activeTask = nil
    }

    private func mapError(_ error: Error) -> NetworkingError {
        if let networkError = error as? NetworkingError { return networkError }
        if let urlError = error as? URLError { return .requestFailed(reason: .urlError(underlying: urlError)) }
        return .requestFailed(reason: .unknownError(underlying: error))
    }
}

// MARK: - ResumableDownloadTaskInterceptor

/// Custom DownloadTaskInterceptor that yields events directly to an AsyncStream continuation.
/// This preserves event ordering since yields happen synchronously in the delegate callback thread.
private class ResumableDownloadTaskInterceptor: DownloadTaskInterceptor {
    var progress: (Double) -> Void = { _ in }

    private let continuation: AsyncStream<DownloadEvent>.Continuation
    private let onCompleted: @Sendable () async -> Void

    init(continuation: AsyncStream<DownloadEvent>.Continuation, onCompleted: @escaping @Sendable () async -> Void) {
        self.continuation = continuation
        self.onCompleted = onCompleted
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        continuation.yield(.completed(location))
        continuation.finish()
        Task { await onCompleted() }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let currentProgress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        continuation.yield(.progress(currentProgress))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        let currentProgress = Double(fileOffset) / Double(expectedTotalBytes)
        continuation.yield(.progress(currentProgress))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error else { return }
        let networkingError: NetworkingError
        if let ne = error as? NetworkingError {
            networkingError = ne
        } else if let urlError = error as? URLError {
            networkingError = .requestFailed(reason: .urlError(underlying: urlError))
        } else {
            networkingError = .requestFailed(reason: .unknownError(underlying: error))
        }
        continuation.yield(.failed(networkingError))
        continuation.finish()
        Task { await onCompleted() }
    }
}
