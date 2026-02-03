import Combine
import Foundation

public protocol RequestPerformable {
    func perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T
    func performTask<T: Decodable>(request: Request, decodeTo decodableObject: T.Type, completion: @escaping ((Result<T, NetworkingError>) -> Void)) -> CancellableRequest
    func performPublisher<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) -> AnyPublisher<T, NetworkingError>
}

// TODO: move to another file

public class CancellableRequest {
    private let onResume: () -> Void
    private let onCancel: () -> Void

    init(
        onResume: @escaping @Sendable (() -> Void),
        onCancel: @escaping @Sendable (() -> Void)
    ) {
        self.onResume = onResume
        self.onCancel = onCancel
    }

    public func resume() {
        onResume()
    }
    public func cancel() {
        onCancel()
    }
}
