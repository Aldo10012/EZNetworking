import Combine
import Foundation

public protocol RequestPerformable {
    func perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T
    func performTask<T: Decodable>(request: Request, decodeTo decodableObject: T.Type, completion: @escaping((Result<T, NetworkingError>) -> Void)) -> URLSessionDataTask?
    func performPublisher<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) -> AnyPublisher<T, NetworkingError>
}

public struct RequestPerformer: RequestPerformable {
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private let requestDecoder: RequestDecodable
    
    public init(urlSession: URLSessionTaskProtocol = URLSession.shared,
                validator: ResponseValidator = ResponseValidatorImpl(),
                requestDecoder: RequestDecodable = RequestDecoder()) {
        self.urlSession = urlSession
        self.validator = validator
        self.requestDecoder = requestDecoder
    }

    // MARK: Async Await
    public func perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            performDataTask(request: request, decodeTo: decodableObject, completion: { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            })
        }
    }

    // MARK: Completion Handler
    @discardableResult
    public func performTask<T: Decodable>(request: Request, decodeTo decodableObject: T.Type, completion: @escaping ((Result<T, NetworkingError>) -> Void)) -> URLSessionDataTask? {
        return performDataTask(request: request, decodeTo: decodableObject, completion: completion)
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

        guard let urlRequest = request.urlRequest else {
            completion(.failure(.internalError(.noRequest)))
            return nil
        }
        let task = urlSession.dataTask(with: urlRequest) { data, urlResponse, error in
            do {
                try validator.validateNoError(error)
                try validator.validateStatus(from: urlResponse)
                let validData = try validator.validateData(data)
                
                let result = try requestDecoder.decode(decodableObject, from: validData)
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
}
