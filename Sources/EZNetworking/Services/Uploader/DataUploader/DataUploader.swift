import Combine
import Foundation

public class DataUploader: DataUploadable {
    private let session: NetworkSession
    private let validator: ResponseValidator

    private let fallbackUploadTaskInterceptor = DefaultUploadTaskInterceptor()

    // MARK: init

    public init(
        session: NetworkSession = Session(),
        validator: ResponseValidator = DefaultResponseValidator()
    ) {
        self.session = session
        self.validator = validator
    }

    // MARK: - CORE - async/await

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

    private func uploadData(_ data: Data, with request: Request, progress: UploadProgressHandler?) async throws -> Data {
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
            return data
        } catch let cancellationError as CancellationError {
            throw cancellationError
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Helpers

    private func mapError(_ error: Error) -> NetworkingError {
        if let networkError = error as? NetworkingError { return networkError }
        if let urlError = error as? URLError { return .requestFailed(reason: .urlError(underlying: urlError)) }
        return .requestFailed(reason: .unknownError(underlying: error.asSendableError))
    }

    private func configureProgressTracking(progress: UploadProgressHandler?) {
        guard let progress else { return }
        if session.delegate.uploadTaskInterceptor == nil {
            session.delegate.uploadTaskInterceptor = fallbackUploadTaskInterceptor
        }
        session.delegate.uploadTaskInterceptor?.progress = progress
    }
}
