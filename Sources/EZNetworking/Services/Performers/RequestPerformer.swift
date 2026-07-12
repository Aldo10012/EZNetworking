import Foundation

public struct RequestPerformer: RequestPerformable {
    private let session: NetworkSession
    private let validator: ResponseValidator
    private let retryPolicy: RetryPolicy
    private let decoder: JSONDecoder

    public init(
        session: NetworkSession = Session(),
        validator: ResponseValidator = DefaultResponseValidator(),
        retryPolicy: RetryPolicy = .none,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.validator = validator
        self.retryPolicy = retryPolicy
        self.decoder = decoder
    }

    public func perform<T: Decodable & Sendable>(
        request: Request,
        decodeTo decodableObject: T.Type
    ) async throws -> T {
        try Task.checkCancellation()
        if retryPolicy.enabled {
            return try await performWithRetry(request: request, decodeTo: decodableObject)
        } else {
            return try await performSingle(request: request, decodeTo: decodableObject)
        }
    }

    // MARK: - Helpers

    private func performSingle<T: Decodable & Sendable>(
        request: Request,
        decodeTo decodableObject: T.Type
    ) async throws -> T {
        do {
            let urlRequest = try request.getURLRequest()
            let (data, urlResponse) = try await session.urlSession.data(for: urlRequest)
            try Task.checkCancellation()
            try validator.validateStatus(from: urlResponse)
            return try decode(data, decodeTo: decodableObject)
        } catch let cancellationError as CancellationError {
            throw cancellationError
        } catch {
            throw mapError(error)
        }
    }

    private func performWithRetry<T: Decodable & Sendable>(
        request: Request,
        decodeTo decodableObject: T.Type
    ) async throws -> T {
        var attemptCount: UInt = 0
        while true {
            do {
                return try await performSingle(request: request, decodeTo: decodableObject)
            } catch let cancellationError as CancellationError {
                throw cancellationError
            } catch {
                attemptCount += 1
                if retryPolicy.hasReachedMaxAttempts(attemptCount) {
                    throw error
                }
                try await retryPolicy.sleep(forAttempt: attemptCount)
            }
        }
    }

    private func decode<T: Decodable & Sendable>(_ data: Data, decodeTo decodableObject: T.Type) throws -> T {
        do {
            return try decoder.decode(decodableObject, from: data)
        } catch let error as DecodingError {
            throw NetworkingError.decodingFailed(reason: .decodingError(underlying: error))
        } catch {
            throw NetworkingError.decodingFailed(reason: .other(underlying: error.asSendableError))
        }
    }

    private func mapError(_ error: Error) -> NetworkingError {
        if let networkError = error as? NetworkingError { return networkError }
        if let urlError = error as? URLError { return .requestFailed(reason: .urlError(underlying: urlError)) }
        return .requestFailed(reason: .unknownError(underlying: error.asSendableError))
    }
}
