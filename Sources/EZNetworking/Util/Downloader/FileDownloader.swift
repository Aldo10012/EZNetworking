import Foundation

public actor FileDownloader: FileDownloadable {
    private let request: DownloadRequest
    private let session: NetworkSession
    private let validator: ResponseValidator

    enum State: Equatable {
        case idle
        case downloading
        case pausing
        case paused(resumeData: Data)
        case completed
        case failed
        case failedButCanResume(resumeData: Data)
        case cancelled
    }

    var state: State = .idle
    private var downloadTask: (any URLSessionDownloadTaskProtocol)?
    private var continuation: AsyncStream<DownloadEvent>.Continuation?

    /// Strong reference since SessionDelegate.downloadTaskInterceptor is weak
    private nonisolated let fallbackDownloadTaskInterceptor: DefaultDownloadTaskInterceptor

    // MARK: init

    public init(
        url: String,
        session: NetworkSession = Session(),
        validator: ResponseValidator = DefaultResponseValidator()
    ) {
        self.init(
            request: DownloadRequest(url: url),
            session: session,
            validator: validator
        )
    }

    public init(
        request: DownloadRequest,
        session: NetworkSession = Session(),
        validator: ResponseValidator = DefaultResponseValidator()
    ) {
        self.request = request
        self.session = session
        self.validator = validator
        fallbackDownloadTaskInterceptor = DefaultDownloadTaskInterceptor(validator: validator)

        setupDownloadEventHandler(session: session)
    }

    // MARK: deinit

    deinit {
        session.delegate.downloadTaskInterceptor?.onEvent = { _ in }
        continuation?.finish()
    }

    // MARK: - downloadFileStream

    public func downloadFileStream() -> AsyncStream<DownloadEvent> {
        guard !Task.isCancelled else {
            return AsyncStream { $0.finish() }
        }

        switch state {
        case .idle:
            break
        case .downloading, .pausing, .paused:
            return earlyExitStream(yielding: .failed(.downloadFailed(reason: .alreadyDownloading)))
        case .failedButCanResume:
            return earlyExitStream(yielding: .failed(.downloadFailed(reason: .downloadIncompleteButResumable)))
        case .completed, .failed, .cancelled:
            return earlyExitStream(yielding: .failed(.downloadFailed(reason: .alreadyFinished)))
        }

        let urlRequest: URLRequest
        do {
            urlRequest = try request.getURLRequest()
        } catch {
            return earlyExitStream(yielding: .failed(mapNetworkingError(from: error)))
        }

        let (stream, continuation) = AsyncStream<DownloadEvent>.makeStream()
        self.continuation = continuation

        continuation.onTermination = { @Sendable [weak self] termination in
            guard case .cancelled = termination else { return }
            Task { [weak self] in
                try? await self?.cancel()
            }
        }

        state = .downloading
        let task = session.urlSession.downloadTaskInspectable(with: urlRequest)
        downloadTask = task
        task.resume()

        return stream
    }

    // MARK: pause

    public func pause() async throws {
        try Task.checkCancellation()
        guard case .downloading = state else {
            throw NetworkingError.downloadFailed(reason: .notDownloading)
        }

        state = .pausing

        let resumeData = await downloadTask?.cancelByProducingResumeData()
        downloadTask = nil

        guard case .pausing = state else { return }
        guard !Task.isCancelled else {
            terminateSilently(state: .cancelled)
            return
        }
        guard let resumeData else {
            terminate(with: .failed(.downloadFailed(reason: .cannotResume)), state: .failed)
            return
        }
        state = .paused(resumeData: resumeData)
    }

    // MARK: resume

    public func resume() async throws {
        try Task.checkCancellation()

        let resumeData: Data
        switch state {
        case let .paused(data):
            resumeData = data
        case let .failedButCanResume(data):
            resumeData = data
        default:
            throw NetworkingError.downloadFailed(reason: .notPaused)
        }

        state = .downloading
        let task = session.urlSession.downloadTaskInspectable(withResumeData: resumeData)
        downloadTask = task
        task.resume()
    }

    // MARK: cancel

    public func cancel() throws {
        switch state {
        case .downloading, .paused, .pausing, .failedButCanResume:
            break
        case .idle:
            throw NetworkingError.downloadFailed(reason: .notDownloading)
        case .completed, .failed, .cancelled:
            throw NetworkingError.downloadFailed(reason: .alreadyFinished)
        }

        downloadTask?.cancel()
        terminateSilently(state: .cancelled)
    }

    // MARK: - Helpers

    private nonisolated func earlyExitStream(yielding value: DownloadEvent) -> AsyncStream<DownloadEvent> {
        AsyncStream { continuation in
            continuation.yield(value)
            continuation.finish()
        }
    }

    /// Moves to a terminal state, yields a final event, and closes the stream.
    private func terminate(with event: DownloadEvent, state newState: State) {
        state = newState
        downloadTask = nil
        continuation?.yield(event)
        continuation?.finish()
        continuation = nil
    }

    /// Moves to a terminal state and closes the stream without yielding any event.
    private func terminateSilently(state newState: State) {
        state = newState
        downloadTask = nil
        continuation?.finish()
        continuation = nil
    }

    // MARK: - Event handling

    private nonisolated func setupDownloadEventHandler(session: NetworkSession) {
        if session.delegate.downloadTaskInterceptor == nil {
            session.delegate.downloadTaskInterceptor = fallbackDownloadTaskInterceptor
        }

        session.delegate.downloadTaskInterceptor?.onEvent = { [weak self] event in
            Task { @Sendable [weak self] in
                await self?.handleDownloadInterceptorEvent(event)
            }
        }
    }

    private func handleDownloadInterceptorEvent(_ event: DownloadTaskInterceptorEvent) {
        switch event {
        case let .onProgress(progress):
            guard case .downloading = state else { return }
            continuation?.yield(.progress(progress))

        case let .onDownloadCompleted(location):
            switch state {
            case .downloading, .pausing: break
            default: return
            }
            terminate(with: .completed(location), state: .completed)

        case let .onDownloadFailed(error, resumeData):
            guard case .downloading = state else { return }
            downloadTask = nil

            if let resumeData {
                state = .failedButCanResume(resumeData: resumeData)
                let resumableError: NetworkingError = .downloadFailed(
                    reason: .failedButResumable(underlying: error.asSendableError)
                )
                continuation?.yield(.failed(resumableError))
            } else {
                let networkError = mapNetworkingError(from: error)
                terminate(with: .failed(networkError), state: .failed)
            }
        }
    }

    private func mapNetworkingError(from error: Error) -> NetworkingError {
        switch error {
        case let networkingError as NetworkingError:
            networkingError
        case let urlError as URLError:
            .downloadFailed(reason: .urlError(underlying: urlError))
        default:
            .downloadFailed(reason: .unknownError(underlying: error.asSendableError))
        }
    }
}
