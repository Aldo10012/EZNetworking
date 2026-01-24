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
        try await withCheckedThrowingContinuation { continuation in
            performDataTask(request: request, decodeTo: decodableObject, completion: { result in
                switch result {
                case let .success(success):
                    continuation.resume(returning: success)
                case let .failure(failure):
                    continuation.resume(throwing: failure)
                }
            })
        }
    }

    // MARK: Completion Handler

    @discardableResult
    public func performTask<T: Decodable>(request: Request, decodeTo decodableObject: T.Type, completion: @escaping ((Result<T, NetworkingError>) -> Void)) -> URLSessionDataTask? {
        performDataTask(request: request, decodeTo: decodableObject, completion: completion)
    }

    // MARK: Publisher

    public func performPublisher<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) -> AnyPublisher<T, NetworkingError> {
        Future { promise in
            performDataTask(request: request, decodeTo: decodableObject) { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: Core

    @discardableResult
    private func performDataTask<T: Decodable>(request: Request, decodeTo decodableObject: T.Type, completion: @escaping ((Result<T, NetworkingError>) -> Void)) -> URLSessionDataTask? {
        guard let urlRequest = getURLRequest(from: request) else {
            completion(.failure(.internalError(.noRequest)))
            return nil
        }
        let task = session.urlSession.dataTask(with: urlRequest) { data, urlResponse, error in
            do {
                try validator.validateNoError(error)
                try validator.validateStatus(from: urlResponse)
                let validData = try validator.validateData(data)

                let result = try decoder.decode(decodableObject, from: validData)
                completion(.success(result))
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

    private func getURLRequest(from request: Request) -> URLRequest? {
        do { return try request.getURLRequest() } catch { return nil }
    }
}
