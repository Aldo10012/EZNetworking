import Foundation

public actor FileUploader: FileUploadable {
    private let url: URL
    private let fileURL: URL
    private let session: NetworkSession
    private let validator: ResponseValidator

    enum State: Equatable {
        case idle
        case uploading
        case pausing
        case paused(resumeData: Data)
        case completed
        case failed
        case failedButCanResume(resumeData: Data)
        case cancelled
    }

    var state: State = .idle
    private var uploadTask: (any URLSessionUploadTaskProtocol)?
    private var continuation: AsyncStream<UploadEvent>.Continuation?

    /// Strong reference since SessionDelegate.uploadTaskInterceptor is weak
    private nonisolated let fallbackUploadTaskInterceptor: DefaultUploadTaskInterceptor

    // MARK: init

    public init(
        url: URL,
        fileURL: URL,
        session: NetworkSession = Session(),
        validator: ResponseValidator = DefaultResponseValidator()
    ) {
        self.url = url
        self.fileURL = fileURL
        self.session = session
        self.validator = validator
        fallbackUploadTaskInterceptor = DefaultUploadTaskInterceptor(validator: validator)

        setupUploadEventHandler(session: session)
    }

    // MARK: deinit

    deinit {
        session.delegate.uploadTaskInterceptor?.onEvent = { _ in }
        continuation?.finish()
    }

    // MARK: - uploadFileStream

    public func uploadFileStream() -> AsyncStream<UploadEvent> {
        guard !Task.isCancelled else {
            return AsyncStream { $0.finish() }
        }

        switch state {
        case .idle:
            break
        case .uploading, .pausing, .paused:
            return earlyExitStream(yielding: .failed(.uploadFailed(reason: .alreadyUploading)))
        case .failedButCanResume:
            return earlyExitStream(yielding: .failed(.uploadFailed(reason: .uploadIncompleteButResumable)))
        case .completed, .failed, .cancelled:
            return earlyExitStream(yielding: .failed(.uploadFailed(reason: .alreadyFinished)))
        }

        let (stream, continuation) = AsyncStream<UploadEvent>.makeStream()
        self.continuation = continuation

        continuation.onTermination = { @Sendable [weak self] termination in
            guard case .cancelled = termination else { return }
            Task { [weak self] in
                try? await self?.cancel()
            }
        }

        state = .uploading
        let request = URLRequest(url: url)
        let task = session.urlSession.uploadTaskInspectable(with: request, fromFile: fileURL)
        uploadTask = task
        task.resume()

        return stream
    }

    // MARK: pause

    public func pause() async throws {
        try Task.checkCancellation()
        guard case .uploading = state else {
            throw NetworkingError.uploadFailed(reason: .notUploading)
        }

        state = .pausing

        let resumeData = await uploadTask?.cancelByProducingResumeData()
        uploadTask = nil

        guard case .pausing = state else { return }
        guard !Task.isCancelled else {
            terminateSilently(state: .cancelled)
            return
        }
        guard let resumeData else {
            terminate(with: .failed(.uploadFailed(reason: .cannotResume)), state: .failed)
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
            throw NetworkingError.uploadFailed(reason: .notPaused)
        }

        state = .uploading
        let task = session.urlSession.uploadTaskInspectable(withResumeData: resumeData)
        uploadTask = task
        task.resume()
    }

    // MARK: cancel

    public func cancel() throws {
        switch state {
        case .uploading, .paused, .pausing, .failedButCanResume:
            break
        case .idle:
            throw NetworkingError.uploadFailed(reason: .notUploading)
        case .completed, .failed, .cancelled:
            throw NetworkingError.uploadFailed(reason: .alreadyFinished)
        }

        uploadTask?.cancel()
        terminateSilently(state: .cancelled)
    }

    // MARK: - Helpers

    private nonisolated func earlyExitStream(yielding value: UploadEvent) -> AsyncStream<UploadEvent> {
        AsyncStream { continuation in
            continuation.yield(value)
            continuation.finish()
        }
    }

    /// Moves to a terminal state, yields a final event, and closes the stream.
    private func terminate(with event: UploadEvent, state newState: State) {
        state = newState
        uploadTask = nil
        continuation?.yield(event)
        continuation?.finish()
        continuation = nil
    }

    /// Moves to a terminal state and closes the stream without yielding any event.
    private func terminateSilently(state newState: State) {
        state = newState
        uploadTask = nil
        continuation?.finish()
        continuation = nil
    }

    // MARK: - Event handling

    private nonisolated func setupUploadEventHandler(session: NetworkSession) {
        if session.delegate.uploadTaskInterceptor == nil {
            session.delegate.uploadTaskInterceptor = fallbackUploadTaskInterceptor
        }

        session.delegate.uploadTaskInterceptor?.onEvent = { [weak self] event in
            Task { @Sendable [weak self] in
                await self?.handleUploadInterceptorEvent(event)
            }
        }
    }

    private func handleUploadInterceptorEvent(_ event: UploadTaskInterceptorEvent) {
        switch event {
        case let .onProgress(progress):
            guard case .uploading = state else { return }
            continuation?.yield(.progress(progress))

        case let .onUploadCompleted(data):
            switch state {
            case .uploading, .pausing: break
            default: return
            }
            terminate(with: .completed(data), state: .completed)

        case let .onUploadFailed(error, resumeData):
            guard case .uploading = state else { return }
            uploadTask = nil

            if let resumeData {
                state = .failedButCanResume(resumeData: resumeData)
                let resumableError: NetworkingError = .uploadFailed(
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
            .uploadFailed(reason: .urlError(underlying: urlError))
        default:
            .uploadFailed(reason: .unknownError(underlying: error.asSendableError))
        }
    }
}
