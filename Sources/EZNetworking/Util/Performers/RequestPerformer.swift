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

    public func perform<T: Decodable & Sendable>(
        request: Request,
        decodeTo decodableObject: T.Type
    ) async throws -> T {
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
    public func performTask<T: Decodable & Sendable>(
        request: Request,
        decodeTo decodableObject: T.Type,
        completion: @escaping (Result<T, NetworkingError>) -> Void
    ) -> CancellableRequest {
        let taskBox = TaskBox()
        let cancellableRequest = CancellableRequest {
            taskBox.task = createTaskAndPerform(request: request, decodeTo: decodableObject, completion: completion)
        } onCancel: {
            taskBox.task?.cancel()
        }
        cancellableRequest.resume()
        return cancellableRequest
    }

    // MARK: Publisher

    public func performPublisher<T: Decodable & Sendable>(
        request: Request,
        decodeTo decodableObject: T.Type
    ) -> AnyPublisher<T, NetworkingError> {
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

    private func createTaskAndPerform<T: Decodable & Sendable>(
        request: Request,
        decodeTo decodableObject: T.Type,
        completion: @escaping ((Result<T, NetworkingError>) -> Void)
    ) -> Task<Void, Never> {
        Task {
            do {
                let result = try await perform(request: request, decodeTo: decodableObject)
                guard !Task.isCancelled else { return }
                completion(.success(result))
            } catch is CancellationError {
                // Task has been cancelled, do not return
            } catch {
                guard !Task.isCancelled else { return }
                completion(.failure(mapError(error)))
            }
        }
    }

    private func mapError(_ error: Error) -> NetworkingError {
        if let networkError = error as? NetworkingError { return networkError }
        if let urlError = error as? URLError { return .urlError(urlError) }
        return .internalError(.requestFailed(error))
    }
}

// for Swift 6 compliance
final class TaskBox: @unchecked Sendable {
    private let lock = NSLock()
    private var _task: Task<Void, Never>?

    var task: Task<Void, Never>? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _task
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _task = newValue
        }
    }
}
