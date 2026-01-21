import Combine
import Foundation

public struct RequestPerformer: RequestPerformable {
    private let urlSession: URLSessionProtocol
    private let validator: ResponseValidator
    private let requestDecoder: RequestDecodable

    public init(
        urlSession: URLSessionProtocol = URLSession.shared,
        validator: ResponseValidator = ResponseValidatorImpl(),
        requestDecoder: RequestDecodable = RequestDecoder(),
        sessionDelegate: SessionDelegate? = nil
    ) {
        if let urlSession = urlSession as? URLSession {
            // If the session already has a delegate, use it (if it's a SessionDelegate)
            if urlSession.delegate is SessionDelegate {
                self.urlSession = urlSession
            } else {
                // If no delegate or not a SessionDelegate, create one
                let newDelegate = sessionDelegate ?? SessionDelegate()
                let newSession = URLSession(
                    configuration: urlSession.configuration,
                    delegate: newDelegate,
                    delegateQueue: urlSession.delegateQueue
                )
                self.urlSession = newSession
            }
        } else {
            // For mocks or custom protocol types
            self.urlSession = urlSession
        }
        self.validator = validator
        self.requestDecoder = requestDecoder
    }

    // MARK: Async Await

    public func perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T {
        return try await _perform(request: request, decodeTo: decodableObject)
    }

    // MARK: Completion Handler

    @discardableResult
    public func performTask<T: Decodable & Sendable>(
        request: Request,
        decodeTo decodableObject: T.Type,
        completion: @escaping ((Result<T, NetworkingError>) -> Void)
    ) -> URLSessionDataTask? {
        let dataTask = EZURLSessionDataTask {
            do {
                let result = try await self._perform(request: request, decodeTo: decodableObject)
                guard !Task.isCancelled else { return }
                completion(.success(result))
            } catch {
                completion(.failure(self.mapError(error)))
            }
        }
        dataTask.resume()
        return dataTask
    }

    // MARK: Publisher

    public func performPublisher<T: Decodable & Sendable>(request: Request, decodeTo decodableObject: T.Type) -> AnyPublisher<T, NetworkingError> {
        var task: Task<Void, Never>?

        return Future { promise in
            task = Task(priority: .high) {
                do {
                    let result = try await self._perform(request: request, decodeTo: decodableObject)
                    guard !Task.isCancelled else { return }
                    promise(.success(result))
                } catch {
                    promise(.failure(mapError(error)))
                }
            }
        }
        .handleEvents(receiveCancel: {
            task?.cancel()
        })
        .eraseToAnyPublisher()
    }

    // MARK: Core

    private func _perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T {
        do {
            let urlReequest = try request.getURLRequest()
            let (data, urlResponse) = try await urlSession.data(for: urlReequest)
            try validator.validateStatus(from: urlResponse)
            let validData = try validator.validateData(data)
            let result = try requestDecoder.decode(decodableObject, from: validData)
            return result
        } catch {
            throw mapError(error)
        }
    }

    private func mapError(_ error: Error) -> NetworkingError {
        if let networkError = error as? NetworkingError { return networkError }
        if let urlError = error as? URLError { return .urlError(urlError) }
        return .internalError(.requestFailed(error))
    }
}
