import Combine
import Foundation

public typealias DownloadProgressHandler = (Double) -> Void
public typealias DownloadCompletionHandler = (Result<URL, NetworkingError>) -> Void

public enum DownloadStreamEvent {
    case progress(Double)
    case success(URL)
    case failure(NetworkingError)
}

public protocol FileDownloadable {
    func downloadFile(from serverUrl: URL, progress: DownloadProgressHandler?) async throws -> URL
    func downloadFileTask(from serverUrl: URL, progress: DownloadProgressHandler?, completion: @escaping(DownloadCompletionHandler)) -> URLSessionDownloadTask
    func downloadFilePublisher(from serverUrl: URL, progress: DownloadProgressHandler?) -> AnyPublisher<URL, NetworkingError>
    func downloadFileStream(url: URL) -> AsyncStream<DownloadStreamEvent>
}

public class FileDownloader: FileDownloadable {
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private let requestDecoder: RequestDecodable
    private var sessionDelegate: SessionDelegate

    private let fallbackDownloadTaskInterceptor: DownloadTaskInterceptor = DefaultDownloadTaskInterceptor()
    
    // MARK: init

    public init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        validator: ResponseValidator = ResponseValidatorImpl(),
        requestDecoder: RequestDecodable = RequestDecoder(),
        sessionDelegate: SessionDelegate? = nil // Now optional!
    ) {
        if let urlSession = urlSession as? URLSession {
            // If the session already has a delegate, use it (if it's a SessionDelegate)
            if let existingDelegate = urlSession.delegate as? SessionDelegate {
                self.sessionDelegate = existingDelegate
                self.urlSession = urlSession
            } else {
                // If no delegate or not a SessionDelegate, create one
                let newDelegate = sessionDelegate ?? SessionDelegate()
                let newSession = URLSession(
                    configuration: urlSession.configuration,
                    delegate: newDelegate,
                    delegateQueue: urlSession.delegateQueue
                )
                self.sessionDelegate = newDelegate
                self.urlSession = newSession
            }
        } else {
            // For mocks or custom protocol types
            self.sessionDelegate = sessionDelegate ?? SessionDelegate()
            self.urlSession = urlSession
        }
        self.validator = validator
        self.requestDecoder = requestDecoder
    }
    
    // MARK: Async Await

    public func downloadFile(from serverUrl: URL, progress: DownloadProgressHandler? = nil) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            _downloadFileTask(url: serverUrl, progress: progress) { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: Completion Handler

    @discardableResult
    public func downloadFileTask(from serverUrl: URL, progress: DownloadProgressHandler?, completion: @escaping(DownloadCompletionHandler)) -> URLSessionDownloadTask {
        return _downloadFileTask(url: serverUrl, progress: progress, completion: completion)
    }

    // MARK: Publisher

    public func downloadFilePublisher(from serverUrl: URL, progress: DownloadProgressHandler?) -> AnyPublisher<URL, NetworkingError> {
        Future { promise in
            self._downloadFileTask(url: serverUrl, progress: progress) { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: AsyncStream

    public func downloadFileStream(url: URL) -> AsyncStream<DownloadStreamEvent> {
        AsyncStream { continuation in
            // Progress handler yields progress updates to the stream.
            let progressHandler: DownloadProgressHandler = { progress in
                continuation.yield(.progress(progress))
            }
            // Start the download task, yielding completion to the stream.
            let task = self._downloadFileTask(url: url, progress: progressHandler) { result in
                switch result {
                case .success(let url):
                    continuation.yield(.success(url))
                case .failure(let error):
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
    private func _downloadFileTask(url: URL, progress: DownloadProgressHandler?, completion: @escaping(DownloadCompletionHandler)) -> URLSessionDownloadTask {
        configureProgressTracking(progress: progress)

        let task = urlSession.downloadTask(with: url) { [weak self] localURL, response, error in
            guard let self else {
                completion(.failure(.internalError(.lostReferenceOfSelf)))
                return
            }
            do {
                try self.validator.validateNoError(error)
                try self.validator.validateStatus(from: response)
                let localURL = try self.validator.validateUrl(localURL)
                
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

        if sessionDelegate.downloadTaskInterceptor != nil {
            // Update existing interceptor's progress handler
            sessionDelegate.downloadTaskInterceptor?.progress = progress
        } else {
            // Set up fallback interceptor with progress handler
            fallbackDownloadTaskInterceptor.progress = progress
            sessionDelegate.downloadTaskInterceptor = fallbackDownloadTaskInterceptor
        }
    }
}

// MARK: - DefaultDownloadTaskInterceptor

/// Default implementation of DownloadTaskInterceptor
private class DefaultDownloadTaskInterceptor: DownloadTaskInterceptor {
    var progress: (Double) -> Void
    
    init(progress: @escaping (Double) -> Void = { _ in }) {
        self.progress = progress
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        progress(1.0)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let currentProgress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progress(currentProgress)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        let currentProgress = Double(fileOffset) / Double(expectedTotalBytes)
        progress(currentProgress)
    }
}
