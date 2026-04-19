import Foundation

public actor FileDownloader: FileDownloadable {
    private let request: DownloadRequest
    private let session: NetworkSession
    private let validator: ResponseValidator
    private var state: DownloadState = .idle
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
        if let failureReason = validateCanStartDownload() {
            return earlyExitStream(yielding: .failed(.downloadFailed(reason: failureReason)))
        }

        let (stream, continuation) = AsyncStream<DownloadEvent>.makeStream()
        self.continuation = continuation

        continuation.onTermination = { @Sendable [weak self] termination in
            guard case .cancelled = termination else { return }
            Task { [weak self] in
                try? await self?.cancel()
            }
        }

        do {
            let urlRequest = try request.getURLRequest()
            state = .downloading
            let task = session.urlSession.downloadTaskInspectable(with: urlRequest)
            downloadTask = task
            task.resume()
            return stream
        } catch {
            return earlyExitStream(yielding: .failed(mapNetworkingError(from: error)))
        }
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
            terminate(yield: nil, state: .cancelled)
            return
        }
        guard let resumeData else {
            terminate(yield: .failed(.downloadFailed(reason: .cannotResume)), state: .failed)
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
        terminate(yield: nil, state: .cancelled)
    }
}

// MARK: - Helpers

extension FileDownloader {
    private func validateCanStartDownload() -> DownloadFailureReason? {
        switch state {
        case .idle:
            return nil  // OK to proceed
        case .downloading, .pausing, .paused:
            return .alreadyDownloading
        case .failedButCanResume:
            return .downloadIncompleteButResumable
        case .completed, .failed, .cancelled:
            return .alreadyFinished
        }
    }

    private nonisolated func earlyExitStream(yielding value: DownloadEvent) -> AsyncStream<DownloadEvent> {
        AsyncStream { continuation in
            continuation.yield(value)
            continuation.finish()
        }
    }

    /// Moves to a terminal state and closes the stream.
    /// - If `event` is non-nil, it is yielded before the stream is finished.
    /// - If `event` is nil, the stream is finished without yielding.
    private func terminate(yield event: DownloadEvent?, state newState: DownloadState) {
        state = newState
        downloadTask = nil
        if let event {
            continuation?.yield(event)
        }
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
            terminate(yield: .completed(location), state: .completed)

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
                terminate(yield: .failed(networkError), state: .failed)
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
