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
        try await withCheckedThrowingContinuation { continuation in
            performDownloadTask(url: serverUrl, progress: progress) { result in
                switch result {
                case let .success(success):
                    continuation.resume(returning: success)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: Completion Handler

    @discardableResult
    public func downloadFileTask(from serverUrl: URL, progress: DownloadProgressHandler?, completion: @escaping (DownloadCompletionHandler)) -> URLSessionDownloadTask {
        performDownloadTask(url: serverUrl, progress: progress, completion: completion)
    }

    // MARK: Publisher

    public func downloadFilePublisher(from serverUrl: URL, progress: DownloadProgressHandler?) -> AnyPublisher<URL, NetworkingError> {
        Future { promise in
            self.performDownloadTask(url: serverUrl, progress: progress) { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: AsyncStream

    public func downloadFileStream(from serverUrl: URL) -> AsyncStream<DownloadStreamEvent> {
        AsyncStream { continuation in
            // Progress handler yields progress updates to the stream.
            let progressHandler: DownloadProgressHandler = { progress in
                continuation.yield(.progress(progress))
            }
            // Start the download task, yielding completion to the stream.
            let task = self.performDownloadTask(url: serverUrl, progress: progressHandler) { result in
                switch result {
                case let .success(url):
                    continuation.yield(.success(url))
                case let .failure(error):
                    continuation.yield(.failure(error))
                }
                continuation.finish()
            }
            // Cancel the task if the stream is terminated.
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    // MARK: - Core

    @discardableResult
    private func performDownloadTask(url: URL, progress: DownloadProgressHandler?, completion: @escaping (DownloadCompletionHandler)) -> URLSessionDownloadTask {
        configureProgressTracking(progress: progress)

        let task = session.urlSession.downloadTask(with: url) { [weak self] localURL, response, error in
            guard let self else {
                completion(.failure(.internalError(.lostReferenceOfSelf)))
                return
            }
            do {
                try validator.validateNoError(error)
                try validator.validateStatus(from: response)
                let localURL = try validator.validateUrl(localURL)

                completion(.success(localURL))
            } catch {
                completion(.failure(mapError(error)))
            }
        }
        task.resume()
        return task
    }

    private func mapError(_ error: Error) -> NetworkingError {
        if let networkError = error as? NetworkingError { return networkError }
        if let urlError = error as? URLError { return .urlError(urlError) }
        return .internalError(.unknown)
    }

    private func configureProgressTracking(progress: DownloadProgressHandler?) {
        guard let progress else { return }

        if session.delegate.downloadTaskInterceptor != nil {
            // Update existing interceptor's progress handler
            session.delegate.downloadTaskInterceptor?.progress = progress
        } else {
            // Set up fallback interceptor with progress handler
            fallbackDownloadTaskInterceptor.progress = progress
            session.delegate.downloadTaskInterceptor = fallbackDownloadTaskInterceptor
        }
    }
}
