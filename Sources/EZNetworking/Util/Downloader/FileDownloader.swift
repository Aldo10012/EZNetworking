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

    // MARK: Async Await

    public func downloadFile(from serverUrl: URL, progress: DownloadProgressHandler? = nil) async throws -> URL {
        for await event in downloadFileStream(from: serverUrl) {
            switch event {
            case .progress(let value):
                progress?(value)
            case .success(let url):
                return url
            case .failure(let error):
                throw error
            }
        }
        throw NetworkingError.internalError(.unknown)
    }

    // MARK: Completion Handler

    @discardableResult
    public func downloadFileTask(from serverUrl: URL, progress: DownloadProgressHandler?, completion: @escaping (DownloadCompletionHandler)) -> CancellableRequest {
        let taskBox = TaskBox()
        let cancellableRequest = CancellableRequest { [weak self] in
            taskBox.task = self?.createTaskAndPerform(from: serverUrl, progress: progress, completion: completion)
        } onCancel: {
            taskBox.task?.cancel()
        }
        cancellableRequest.resume()
        return cancellableRequest
    }

    // MARK: Publisher

    public func downloadFilePublisher(from serverUrl: URL, progress: DownloadProgressHandler?) -> AnyPublisher<URL, NetworkingError> {
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

    // MARK: AsyncStream

    public func downloadFileStream(from serverUrl: URL) -> AsyncStream<DownloadStreamEvent> {
        AsyncStream { continuation in
            configureProgressTracking { progress in
                continuation.yield(.progress(progress))
            }
            let task = Task {
                do {
                    let (localURL, response) = try await session.urlSession.download(from: serverUrl, delegate: nil)
                    try validator.validateStatus(from: response)
                    let url = try validator.validateUrl(localURL)
                    continuation.yield(.success(url))
                    continuation.finish()
                } catch is CancellationError {
                    // optional: silently finish or emit failure
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

    // MARK: - Helpers

    private func createTaskAndPerform(
        from serverUrl: URL,
        progress: DownloadProgressHandler?,
        completion: @escaping ((Result<URL, NetworkingError>) -> Void)
    ) -> Task<Void, Never> {
        Task {
            for await event in downloadFileStream(from: serverUrl) {
                switch event {
                case .progress(let value):
                    progress?(value)
                case .success(let url):
                    guard !Task.isCancelled else { return }
                    completion(.success(url))
                case .failure(let error):
                    guard !Task.isCancelled else { return }
                    completion(.failure(error))
                }
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
