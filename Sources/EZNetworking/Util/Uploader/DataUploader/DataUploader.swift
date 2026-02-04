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
            case let .progress(double):
                progress?(double)
            case let .success(data):
                return data
            case let .failure(error):
                throw error
            }
        }
        throw NetworkingError.internalError(.unknown)
    }

    // MARK: Completion Handler

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

    // MARK: Publisher

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

    // MARK: Helpers

    private func createTaskAndPerform(
        _ data: Data,
        with request: Request,
        progress: UploadProgressHandler?,
        completion: @escaping ((Result<Data, NetworkingError>) -> Void)
    ) -> Task<Void, Never> {
        Task {
            for await event in uploadDataStream(data, with: request) {
                switch event {
                case let .progress(double):
                    progress?(double)
                case let .success(data):
                    guard !Task.isCancelled else { return }
                    completion(.success(data))
                case let .failure(error):
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

    private func configureProgressTracking(progress: UploadProgressHandler?) {
        guard let progress else { return }
        if session.delegate.uploadTaskInterceptor == nil {
            session.delegate.uploadTaskInterceptor = fallbackUploadTaskInterceptor
        }
        session.delegate.uploadTaskInterceptor?.progress = progress
    }
}
