import Foundation
import Combine

public class DataUploader: DataUploadable {
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private var sessionDelegate: SessionDelegate
    
    private let fallbackUploadTaskInterceptor: DefaultUploadTaskInterceptor = DefaultUploadTaskInterceptor()
    
    // MARK: init
    
    public init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        validator: ResponseValidator = ResponseValidatorImpl(),
        sessionDelegate: SessionDelegate? = nil
    ) {
        if let urlSession = urlSession as? URLSession {
            if let existingDelegate = urlSession.delegate as? SessionDelegate {
                self.sessionDelegate = existingDelegate
                self.urlSession = urlSession
            } else {
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
            self.sessionDelegate = sessionDelegate ?? SessionDelegate()
            self.urlSession = urlSession
        }
        self.validator = validator
    }
    
    // MARK: Async Await
    
    public func uploadData(_ data: Data, with request: Request, progress: UploadProgressHandler?) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            self._uploadDataTask(data, with: request, progress: progress) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: Completion Handler
    
    @discardableResult
    public func uploadDataTask(_ data: Data, with request: Request, progress: UploadProgressHandler?, completion: @escaping (UploadCompletionHandler)) -> URLSessionUploadTask? {
        return _uploadDataTask(data, with: request, progress: progress, completion: completion)
    }
    
    // MARK: Publisher
    
    public func uploadDataPublisher(_ data: Data, with request: Request, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError> {
        Future { promise in
            _ = self._uploadDataTask(data, with: request, progress: progress) { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: Async Stream
    
    public func uploadDataStream(_ data: Data, with request: Request) -> AsyncStream<UploadStreamEvent> {
        AsyncStream { continuation in
            let progressHandler: UploadProgressHandler = { progress in
                continuation.yield(.progress(progress))
            }
            let task = self._uploadDataTask(data, with: request, progress: progressHandler) { result in
                switch result {
                case .success(let data):
                    continuation.yield(.success(data))
                case .failure(let error):
                    continuation.yield(.failure(error))
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable _ in
                task?.cancel()
            }
        }
    }
    
    // MARK: Core
    
    @discardableResult
    private func _uploadDataTask(_ data: Data, with request: Request, progress: UploadProgressHandler?, completion: @escaping (UploadCompletionHandler)) -> URLSessionUploadTask? {
        let request = request
        configureProgressTracking(progress: progress)
        
        guard let urlRequest = request.getURLRequest() else {
            completion(.failure(.internalError(.noRequest)))
            return nil
        }
        
        let task = urlSession.uploadTask(with: urlRequest, from: data) { [weak self] data, response, error in
            guard let self else {
                completion(.failure(.internalError(.lostReferenceOfSelf)))
                return
            }
            do {
                try self.validator.validateNoError(error)
                try self.validator.validateStatus(from: response)
                let validData = try self.validator.validateData(data)
                completion(.success(validData))
            } catch {
                completion(.failure(self.mapError(error)))
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
    
    private func configureProgressTracking(progress: UploadProgressHandler?) {
        guard let progress else { return }
        if sessionDelegate.uploadTaskInterceptor != nil {
            sessionDelegate.uploadTaskInterceptor?.progress = progress
        } else {
            fallbackUploadTaskInterceptor.progress = progress
            sessionDelegate.uploadTaskInterceptor = fallbackUploadTaskInterceptor
        }
    }
}
