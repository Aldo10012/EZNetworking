import Combine
import Foundation

public class DataUploader: DataUploadable {
    private let session: NetworkSession
    private let validator: ResponseValidator

    private let fallbackUploadTaskInterceptor = DefaultUploadTaskInterceptor()

    // MARK: init

    public init(
        session: NetworkSession = Session(),
        validator: ResponseValidator = ResponseValidatorImpl()
    ) {
        self.session = session
        self.validator = validator
    }

    // MARK: Async Await

    public func uploadData(_ data: Data, with request: Request, progress: UploadProgressHandler?) async throws -> Data {
        for await event in uploadDataStream(data, with: request) {
            switch event {
            case .progress(let double):
                progress?(double)
            case .success(let data):
                return data
            case .failure(let error):
                throw error
            }
        }
        throw NetworkingError.internalError(.unknown)
    }

    // MARK: Completion Handler

    @discardableResult
    public func uploadDataTask(_ data: Data, with request: Request, progress: UploadProgressHandler?, completion: @escaping (UploadCompletionHandler)) -> CancellableRequest {
        let taskBox = TaskBox()
        let cancellableRequest = CancellableRequest {
            taskBox.task = Task {
                for await event in self.uploadDataStream(data, with: request) {
                    switch event {
                    case .progress(let double):
                        progress?(double)
                    case .success(let data):
                        completion(.success(data))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        } onCancel: {
            taskBox.task?.cancel()
        }
        cancellableRequest.resume()
        return cancellableRequest
    }

    // MARK: Publisher

    public func uploadDataPublisher(_ data: Data, with request: Request, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError> {
        Deferred {
            let taskBox = TaskBox()
            return Future<Data, NetworkingError> { promise in
                taskBox.task = Task {
                    for await event in self.uploadDataStream(data, with: request) {
                        switch event {
                        case .progress(let double):
                            progress?(double)
                        case .success(let data):
                            promise(.success(data))
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }
                }
            }
            .handleEvents(receiveCancel: {
                taskBox.task?.cancel()
            })
        }
        .eraseToAnyPublisher()
    }

    // MARK: Async Stream

    public func uploadDataStream(_ data: Data, with request: Request) -> AsyncStream<UploadStreamEvent> {
        AsyncStream { continuation in
            configureProgressTracking { progress in
                continuation.yield(.progress(progress))
            }
            let task = Task {
                do {
                    let urlRequest = try request.getURLRequest()
                    let (data, urlResponse) = try await session.urlSession.upload(for: urlRequest, from: data)
                    try validator.validateStatus(from: urlResponse)
                    let validData = try validator.validateData(data)
                    continuation.yield(.success(validData))
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

    // MARK: Core

    @discardableResult
    private func _uploadDataTask(_ data: Data, with request: Request, progress: UploadProgressHandler?, completion: @escaping (UploadCompletionHandler)) -> URLSessionUploadTask? {
        let request = request
        configureProgressTracking(progress: progress)

        guard let urlRequest = getURLRequest(from: request) else {
            completion(.failure(.internalError(.noRequest)))
            return nil
        }

        let task = session.urlSession.uploadTask(with: urlRequest, from: data) { [weak self] data, response, error in
            guard let self else {
                completion(.failure(.internalError(.lostReferenceOfSelf)))
                return
            }
            do {
                try validator.validateNoError(error)
                try validator.validateStatus(from: response)
                let validData = try validator.validateData(data)
                completion(.success(validData))
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
        return .internalError(.requestFailed(error))
    }

    private func configureProgressTracking(progress: UploadProgressHandler?) {
        guard let progress else { return }
        if session.delegate.uploadTaskInterceptor != nil {
            session.delegate.uploadTaskInterceptor?.progress = progress
        } else {
            fallbackUploadTaskInterceptor.progress = progress
            session.delegate.uploadTaskInterceptor = fallbackUploadTaskInterceptor
        }
    }

    private func getURLRequest(from request: Request) -> URLRequest? {
        do { return try request.getURLRequest() } catch { return nil }
    }
}
