import Combine
import Foundation

public struct RequestPerformer: RequestPerformable {
    private let session: NetworkSession
    private let validator: ResponseValidator
    private let decoder: JSONDecoder

    public init(
        session: NetworkSession = Session(),
        validator: ResponseValidator = ResponseValidatorImpl(),
        decoder: JSONDecoder = EZJSONDecoder()
    ) {
        self.session = session
        self.validator = validator
        self.decoder = decoder
    }

    // MARK: Async Await

    public func perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T {
        do {
            let urlRequest = try request.getURLRequest()
            let (data, urlResponse) = try await session.urlSession.data(for: urlRequest)
            try validator.validateStatus(from: urlResponse)
            let validData = try validator.validateData(data)
            return try decoder.decode(decodableObject, from: validData)
        } catch {
            throw mapError(error)
        }
    }

    // MARK: Completion Handler

    @discardableResult
    public func performTask<T: Decodable>(request: Request, decodeTo decodableObject: T.Type, completion: @escaping ((Result<T, NetworkingError>) -> Void)) -> CancellableRequest {
        var task: Task<Void, Never>?
        let cancellableRequest = CancellableRequest {
            task = createTaskAndPerform(request: request, decodeTo: decodableObject, completion: completion)
        } onCancel: {
            task?.cancel()
        }
        cancellableRequest.resume()
        return cancellableRequest
    }

    // MARK: Publisher

    public func performPublisher<T: Decodable>( request: Request, decodeTo decodableObject: T.Type) -> AnyPublisher<T, NetworkingError> {
        Deferred {
            var task: Task<Void, Never>?

            return Future<T, NetworkingError> { promise in
                task = createTaskAndPerform(request: request, decodeTo: decodableObject, completion: { promise($0) })
            }
            .handleEvents(receiveCancel: {
                task?.cancel()
            })
        }
        .eraseToAnyPublisher()
    }

    // MARK: Helpers

    private func createTaskAndPerform<T: Decodable>(
        request: Request,
        decodeTo decodableObject: T.Type,
        completion: @escaping ((Result<T, NetworkingError>) -> Void)
    ) -> Task<Void, Never> {
        return Task {
            do {
                let result = try await self.perform(request: request, decodeTo: decodableObject)
                guard !Task.isCancelled else { return }
                completion(.success(result))
            } catch is CancellationError {
                // Task has been cancelled, do not return
            } catch {
                guard !Task.isCancelled else { return }
                completion(.failure(self.mapError(error)))
            }
        }
    }

    private func mapError(_ error: Error) -> NetworkingError {
        if let networkError = error as? NetworkingError { return networkError }
        if let urlError = error as? URLError { return .urlError(urlError) }
        return .internalError(.requestFailed(error))
    }
}
