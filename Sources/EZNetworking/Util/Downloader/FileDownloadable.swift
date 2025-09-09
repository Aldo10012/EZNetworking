import Combine
import Foundation

public typealias DownloadProgressHandler = (Double) -> Void
public typealias DownloadCompletionHandler = (Result<URL, NetworkingError>) -> Void

public protocol FileDownloadable {
    func downloadFile(with url: URL, progress: DownloadProgressHandler?) async throws -> URL
    func downloadFileTask(url: URL, progress: DownloadProgressHandler?, completion: @escaping(DownloadCompletionHandler)) -> URLSessionDownloadTask
    func downloadPublisher(url: URL, progress: DownloadProgressHandler?) -> AnyPublisher<URL, NetworkingError>

}

public class FileDownloader: FileDownloadable {
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private let requestDecoder: RequestDecodable
    private var sessionDelegate: SessionDelegate

    private let fallbackDownloadTaskInterceptor: DownloadTaskInterceptor = DefaultDownloadTaskInterceptor()
    
    // MARK: init

    public convenience init(
        sessionConfiguration: URLSessionConfiguration = .default,
        sessionDelegate: SessionDelegate = SessionDelegate(),
        delegateQueue: OperationQueue? = nil,
        validator: ResponseValidator = ResponseValidatorImpl(),
        requestDecoder: RequestDecodable = RequestDecoder()
    ) {
        let urlSession = URLSession(configuration: sessionConfiguration,
                                    delegate: sessionDelegate,
                                    delegateQueue: delegateQueue)
        self.init(urlSession: urlSession,
                  validator: validator,
                  requestDecoder: requestDecoder,
                  sessionDelegate: sessionDelegate)
    }

    public convenience init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        validator: ResponseValidator = ResponseValidatorImpl(),
        requestDecoder: RequestDecodable = RequestDecoder()
    ) {
        self.init(urlSession: urlSession,
                  validator: validator,
                  requestDecoder: requestDecoder,
                  sessionDelegate: SessionDelegate())
    }

    internal init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        validator: ResponseValidator = ResponseValidatorImpl(),
        requestDecoder: RequestDecodable = RequestDecoder(),
        sessionDelegate: SessionDelegate = SessionDelegate()
    ) {
        self.urlSession = urlSession
        self.validator = validator
        self.requestDecoder = requestDecoder
        self.sessionDelegate = sessionDelegate
    }
    
    // MARK: Async Await
    public func downloadFile(with url: URL, progress: DownloadProgressHandler? = nil) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            _downloadFileTask(url: url, progress: progress) { result in
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
    public func downloadFileTask(url: URL, progress: DownloadProgressHandler?, completion: @escaping(DownloadCompletionHandler)) -> URLSessionDownloadTask {
        return _downloadFileTask(url: url, progress: progress, completion: completion)
    }

    // MARK: Publisher
    @discardableResult
    public func downloadPublisher(url: URL, progress: DownloadProgressHandler?) -> AnyPublisher<URL, NetworkingError> {
        Future { promise in
            self._downloadFileTask(url: url, progress: progress) { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
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

    private func configureProgressTracking(progress: ((Double) -> Void)?) {
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
