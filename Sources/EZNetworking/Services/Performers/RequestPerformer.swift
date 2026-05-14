import Foundation

public struct RequestPerformer: RequestPerformable {
    private let session: NetworkSession
    private let validator: ResponseValidator
    private let decoder: JSONDecoder

    public init(
        session: NetworkSession = Session(),
        validator: ResponseValidator = DefaultResponseValidator(),
        decoder: JSONDecoder = EZJSONDecoder()
    ) {
        self.session = session
        self.validator = validator
        self.decoder = decoder
    }

    public func perform<T: Decodable & Sendable>(
        request: Request,
        decodeTo decodableObject: T.Type
    ) async throws -> T {
        try Task.checkCancellation()
        do {
            let urlRequest = try request.getURLRequest()
            let (data, urlResponse) = try await session.urlSession.data(for: urlRequest)
            try Task.checkCancellation()
            try validator.validateStatus(from: urlResponse)
            return try decoder.decode(decodableObject, from: data)
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
}
