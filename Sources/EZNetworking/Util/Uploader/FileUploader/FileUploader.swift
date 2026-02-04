import Combine
import Foundation

public class FileUploader: FileUploadable {
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

    public func uploadFile(_ fileURL: URL, with request: any Request, progress: UploadProgressHandler?) async throws -> Data {
        for await event in uploadFileStream(fileURL, with: request) {
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
    public func uploadFileTask(_ fileURL: URL, with request: any Request, progress: UploadProgressHandler?, completion: @escaping UploadCompletionHandler) -> URLSessionUploadTask? {
        _uploadFileTask(fileURL, with: request, progress: progress, completion: completion)
    }

    // MARK: Publisher

    public func uploadFilePublisher(_ fileURL: URL, with request: any Request, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError> {
        Future { promise in
            _ = self._uploadFileTask(fileURL, with: request, progress: progress) { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: AsyncStream

    public func uploadFileStream(_ fileURL: URL, with request: any Request) -> AsyncStream<UploadStreamEvent> {
        AsyncStream { continuation in
            configureProgressTracking { progress in
                continuation.yield(.progress(progress))
            }
            let task = Task {
                do {
                    let urlRequest = try request.getURLRequest()
                    let (data, urlResponse) = try await session.urlSession.upload(for: urlRequest, fromFile: fileURL)
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

    // MARK: - Core

    @discardableResult
    private func _uploadFileTask(_ fileURL: URL, with request: Request, progress: UploadProgressHandler?, completion: @escaping (UploadCompletionHandler)) -> URLSessionUploadTask? {
        let request = request
        configureProgressTracking(progress: progress)

        guard let urlRequest = getURLRequest(from: request) else {
            completion(.failure(.internalError(.noRequest)))
            return nil
        }

        let task = session.urlSession.uploadTask(with: urlRequest, fromFile: fileURL) { [weak self] data, response, error in
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
        if session.delegate.uploadTaskInterceptor == nil {
            session.delegate.uploadTaskInterceptor = fallbackUploadTaskInterceptor
        }
        session.delegate.uploadTaskInterceptor?.progress = progress
    }

    private func getURLRequest(from request: Request) -> URLRequest? {
        do { return try request.getURLRequest() } catch { return nil }
    }
}
