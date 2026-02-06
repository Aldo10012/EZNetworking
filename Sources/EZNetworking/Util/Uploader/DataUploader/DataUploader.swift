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

    // MARK: - CORE - async/await

    public func uploadData(_ data: Data, with request: Request, progress: UploadProgressHandler?) async throws -> Data {
        try Task.checkCancellation()
        configureProgressTracking { percentage in
            guard !Task.isCancelled else { return }
            progress?(percentage)
        }
        do {
            let urlRequest = try request.getURLRequest()
            let (data, urlResponse) = try await session.urlSession.upload(for: urlRequest, from: data)
            try Task.checkCancellation()
            try validator.validateStatus(from: urlResponse)
            let validData = try validator.validateData(data)
            return validData
        } catch let cancellationError as CancellationError {
            throw cancellationError
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Adapter - AsyncStream

    public func uploadDataStream(_ data: Data, with request: Request) -> AsyncStream<UploadStreamEvent> {
        AsyncStream { continuation in
            let task = Task {
                do {
                    let data = try await uploadData(data, with: request) {
                        continuation.yield(.progress($0))
                    }
                    continuation.yield(.success(data))
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
    public func uploadDataTask(_ data: Data, with request: Request, progress: UploadProgressHandler?, completion: @escaping (UploadCompletionHandler)) -> CancellableRequest {
        let taskBox = TaskBox()
        let cancellableRequest = CancellableRequest { [weak self] in
            taskBox.task = self?.createTaskAndPerform(data, with: request, progress: progress, completion: completion)
        } onCancel: {
            taskBox.task?.cancel()
        }
        cancellableRequest.resume()
        return cancellableRequest
    }

    // MARK: - Adapter - Publisher

    public func uploadDataPublisher(_ data: Data, with request: Request, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError> {
        Deferred {
            let taskBox = TaskBox()
            return Future<Data, NetworkingError> { [weak self] promise in
                taskBox.task = self?.createTaskAndPerform(data, with: request, progress: progress, completion: { promise($0) })
            }
            .handleEvents(receiveCancel: {
                taskBox.task?.cancel()
            })
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Helpers

    private func createTaskAndPerform(
        _ data: Data,
        with request: Request,
        progress: UploadProgressHandler?,
        completion: @escaping ((Result<Data, NetworkingError>) -> Void)
    ) -> Task<Void, Never> {
        Task {
            do {
                let data = try await uploadData(data, with: request, progress: progress)
                completion(.success(data))
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

    private func configureProgressTracking(progress: UploadProgressHandler?) {
        guard let progress else { return }
        if session.delegate.uploadTaskInterceptor == nil {
            session.delegate.uploadTaskInterceptor = fallbackUploadTaskInterceptor
        }
        session.delegate.uploadTaskInterceptor?.progress = progress
    }
}
