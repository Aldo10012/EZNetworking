import Combine
import Foundation

public class FileDownloader: FileDownloadable {
    private let session: NetworkSession
    private let validator: ResponseValidator
    private let decoder: JSONDecoder

    private let fallbackDownloadTaskInterceptor: DownloadTaskInterceptor = DefaultDownloadTaskInterceptor()

    // MARK: init

    public init(
        session: NetworkSession = Session(),
        validator: ResponseValidator = ResponseValidatorImpl(),
        decoder: JSONDecoder = EZJSONDecoder()
    ) {
        self.session = session
        self.validator = validator
        self.decoder = decoder
    }

    // MARK: - CORE - async/await

    public func downloadFile(
        from serverUrl: URL,
        progress: DownloadProgressHandler? = nil
    ) async throws -> URL {
        try Task.checkCancellation()
        configureProgressTracking { percentage in
            guard !Task.isCancelled else { return }
            progress?(percentage)
        }
        do {
            let (localURL, response) = try await session.urlSession.download(from: serverUrl, delegate: nil)
            try Task.checkCancellation()
            try validator.validateStatus(from: response)
            let url = try validator.validateUrl(localURL)
            return url
        } catch let cancellationError as CancellationError {
            throw cancellationError
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Adapter - AsyncStream

    public func downloadFileStream(from serverUrl: URL) -> AsyncStream<DownloadStreamEvent> {
        AsyncStream { continuation in
            let task = Task {
                do {
                    let url = try await downloadFile(from: serverUrl) {
                        continuation.yield(.progress($0))
                    }
                    continuation.yield(.success(url))
                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish()
                } catch {
                    continuation.yield(.failure(mapError(error)))
                    continuation.finish()
                }
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    // MARK: - Adapter - callbacks

    @discardableResult
    public func downloadFileTask(
        from serverUrl: URL,
        progress: DownloadProgressHandler?,
        completion: @escaping (DownloadCompletionHandler)
    ) -> CancellableRequest {
        let taskBox = TaskBox()
        let cancellableRequest = CancellableRequest { [weak self] in
            taskBox.task = self?.createTaskAndPerform(from: serverUrl, progress: progress, completion: completion)
        } onCancel: {
            taskBox.task?.cancel()
        }
        cancellableRequest.resume()
        return cancellableRequest
    }

    // MARK: - Adapter - Publisher

    public func downloadFilePublisher(
        from serverUrl: URL,
        progress: DownloadProgressHandler?
    ) -> AnyPublisher<URL, NetworkingError> {
        Deferred {
            let taskBox = TaskBox()
            return Future<URL, NetworkingError> { [weak self] promise in
                taskBox.task = self?.createTaskAndPerform(from: serverUrl, progress: progress, completion: { promise($0) })
            }
            .handleEvents(receiveCancel: {
                taskBox.task?.cancel()
            })
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Helpers

    private func createTaskAndPerform(
        from serverUrl: URL,
        progress: DownloadProgressHandler?,
        completion: @escaping ((Result<URL, NetworkingError>) -> Void)
    ) -> Task<Void, Never> {
        Task {
            do {
                let url = try await downloadFile(from: serverUrl, progress: progress)
                completion(.success(url))
            } catch is CancellationError {
                // Do nothing, task has been cancelled
            } catch {
                completion(.failure(mapError(error)))
            }
        }
    }

    private func mapError(_ error: Error) -> NetworkingError {
        if let networkError = error as? NetworkingError { return networkError }
        if let urlError = error as? URLError { return .urlError(urlError) }
        return .internalError(.requestFailed(error))
    }

    private func configureProgressTracking(progress: DownloadProgressHandler?) {
        guard let progress else { return }

        if session.delegate.downloadTaskInterceptor == nil {
            session.delegate.downloadTaskInterceptor = fallbackDownloadTaskInterceptor
        }
        session.delegate.downloadTaskInterceptor?.progress = progress
    }
}
