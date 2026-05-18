import Foundation

public actor FileUploader: Uploadable {
    private let fileURL: URL
    private let request: UploadRequest
    private let session: NetworkSession
    private let validator: ResponseValidator
    private var state: UploadState = .idle
    private var uploadTask: (any URLSessionUploadTaskProtocol)?
    private var continuation: AsyncStream<UploadEvent>.Continuation?

    /// Strong reference since SessionDelegate.uploadTaskInterceptor is weak
    private nonisolated let fallbackUploadTaskInterceptor: DefaultUploadTaskInterceptor

    // MARK: init

    public init(
        fileURL: URL,
        request: UploadRequest,
        session: NetworkSession = Session(),
        validator: ResponseValidator = DefaultResponseValidator()
    ) {
        self.fileURL = fileURL
        self.request = request
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

    // MARK: - upload

    public func upload() -> AsyncStream<UploadEvent> {
        guard !Task.isCancelled else {
            return AsyncStream { $0.finish() }
        }
        if let failureReason = validateCanStartUpload() {
            return earlyExitStream(yielding: .failed(.uploadFailed(reason: failureReason)))
        }

        let (stream, continuation) = AsyncStream<UploadEvent>.makeStream()
        self.continuation = continuation

        continuation.onTermination = { @Sendable [weak self] termination in
            guard case .cancelled = termination else { return }
            Task { [weak self] in
                try? await self?.cancel()
            }
        }

        do {
            let urlRequest = try request.getURLRequest()
            state = .uploading
            let task = session.urlSession.uploadTaskInspectable(with: urlRequest, fromFile: fileURL)
            uploadTask = task
            task.resume()
            return stream
        } catch {
            return earlyExitStream(yielding: .failed(mapNetworkingError(from: error)))
        }
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
            terminate(yield: nil, state: .cancelled)
            return
        }
        guard let resumeData else {
            terminate(yield: .failed(.uploadFailed(reason: .cannotResume)), state: .failed)
            return
        }
        state = .paused(resumeData: resumeData)
    }

    // MARK: resume

    public func resume() async throws {
        try Task.checkCancellation()
        guard let resumeData = state.resumeData else {
            throw NetworkingError.uploadFailed(reason: .notPaused)
        }
        state = .uploading
        let task = session.urlSession.uploadTaskInspectable(withResumeData: resumeData)
        uploadTask = task
        task.resume()
    }

    // MARK: cancel

    public func cancel() async throws {
        switch state {
        case .uploading, .paused, .pausing, .failedButCanResume:
            break
        case .idle:
            throw NetworkingError.uploadFailed(reason: .notUploading)
        case .completed, .failed, .cancelled:
            throw NetworkingError.uploadFailed(reason: .alreadyFinished)
        }

        uploadTask?.cancel()
        terminate(yield: nil, state: .cancelled)
    }
}

// MARK: - Helpers

extension FileUploader {
    private func validateCanStartUpload() -> UploadFailureReason? {
        switch state {
        case .idle:
            nil // OK to proceed
        case .uploading, .pausing, .paused:
            .alreadyUploading
        case .failedButCanResume:
            .uploadIncompleteButResumable
        case .completed, .failed, .cancelled:
            .alreadyFinished
        }
    }

    private nonisolated func earlyExitStream(yielding value: UploadEvent) -> AsyncStream<UploadEvent> {
        AsyncStream { continuation in
            continuation.yield(value)
            continuation.finish()
        }
    }

    /// Moves to a terminal state and closes the stream.
    /// - If `event` is non-nil, it is yielded before the stream is finished.
    /// - If `event` is nil, the stream is finished without yielding.
    private func terminate(yield event: UploadEvent?, state newState: UploadState) {
        state = newState
        uploadTask = nil
        if let event {
            continuation?.yield(event)
        }
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
            terminate(yield: .completed(data), state: .completed)

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
                terminate(yield: .failed(networkError), state: .failed)
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
