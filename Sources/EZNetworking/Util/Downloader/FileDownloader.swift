import Foundation

public actor FileDownloader: FileDownloadable {
    private let url: URL
    private let session: NetworkSession
    private let validator: ResponseValidator

    private enum State {
        case idle
        case downloading
        case paused(resumeData: Data?)
        case completed
        case failed
        case cancelled
    }

    private var state: State = .idle
    private var downloadTask: (any URLSessionDownloadTaskProtocol)?
    private var continuation: AsyncStream<DownloadEvent>.Continuation?

    /// Strong reference since SessionDelegate.downloadTaskInterceptor is weak
    private nonisolated let fallbackDownloadTaskInterceptor: DefaultDownloadTaskInterceptor

    // MARK: init

    init(
        url: URL,
        session: NetworkSession = Session(),
        validator: ResponseValidator = DefaultResponseValidator()
    ) {
        self.url = url
        self.session = session
        self.validator = validator
        self.fallbackDownloadTaskInterceptor = DefaultDownloadTaskInterceptor(validator: validator)

        setupDownloadEventHandler()
    }

    // MARK: deinit

    deinit {
        fallbackDownloadTaskInterceptor.onEvent = { _ in }
        continuation?.finish()
    }

    // MARK: - FileDownloadable

    public func downloadFileStream() -> AsyncStream<DownloadEvent> {
        guard case .idle = state else {
            return AsyncStream { continuation in
                continuation.yield(.failed(.downloadFailed(reason: .alreadyDownloading)))
                continuation.finish()
            }
        }

        let (stream, continuation) = AsyncStream<DownloadEvent>.makeStream()
        self.continuation = continuation

        state = .downloading
        let task = session.urlSession.downloadTask(with: url)
        self.downloadTask = task
        task.resume()

        continuation.yield(.started)

        return stream
    }

    public func pause() async throws {
        guard case .downloading = state else {
            throw NetworkingError.downloadFailed(reason: .alreadyDownloading)
        }

        let resumeData = await downloadTask?.cancelByProducingResumeData()
        downloadTask = nil
        state = .paused(resumeData: resumeData)
        continuation?.yield(.paused)
    }

    public func resume() async throws {
        guard case .paused(let resumeData) = state else {
            throw NetworkingError.downloadFailed(reason: .alreadyDownloading)
        }

        guard let resumeData else {
            state = .failed
            let error = NetworkingError.downloadFailed(reason: .cannotResume)
            continuation?.yield(.failed(error))
            continuation?.finish()
            continuation = nil
            throw error
        }

        state = .downloading
        let task = session.urlSession.downloadTask(withResumeData: resumeData)
        self.downloadTask = task
        task.resume()

        continuation?.yield(.resumed)
    }

    public func cancel() throws {
        switch state {
        case .downloading, .paused:
            break
        case .idle, .completed, .failed, .cancelled:
            throw NetworkingError.downloadFailed(reason: .alreadyDownloading)
        }

        downloadTask?.cancel()
        downloadTask = nil
        state = .cancelled
        continuation?.yield(.cancelled)
        continuation?.finish()
        continuation = nil
    }

    // MARK: - Event handling

    private nonisolated func setupDownloadEventHandler() {
        if session.delegate.downloadTaskInterceptor == nil {
            session.delegate.downloadTaskInterceptor = fallbackDownloadTaskInterceptor
        }

        session.delegate.downloadTaskInterceptor?.onEvent = { [weak self] event in
            Task { [weak self] in
                await self?.handleDownloadInterceptorEvent(event)
            }
        }
    }

    private func handleDownloadInterceptorEvent(_ event: DownloadTaskInterceptorEvent) {
        guard case .downloading = state else { return }

        switch event {
        case .onProgress(let progress):
            continuation?.yield(.progress(progress))

        case .onDownloadCompleted(let location):
            state = .completed
            downloadTask = nil
            continuation?.yield(.completed(location))
            continuation?.finish()
            continuation = nil

        case .onDownloadFailed(let error):
            state = .failed
            downloadTask = nil
            let networkError: NetworkingError
            if let ne = error as? NetworkingError {
                networkError = ne
            } else if let urlError = error as? URLError {
                networkError = .downloadFailed(reason: .urlError(underlying: urlError))
            } else {
                networkError = .downloadFailed(reason: .unknownError(underlying: error))
            }
            continuation?.yield(.failed(networkError))
            continuation?.finish()
            continuation = nil
        }
    }
}
