import Combine
import Foundation

public protocol RequestPerformable {
    func perform<T: Decodable & Sendable>(
        request: Request,
        decodeTo decodableObject: T.Type
    ) async throws -> T

    func performTask<T: Decodable & Sendable>(
        request: Request,
        decodeTo decodableObject: T.Type,
        completion: @escaping ((Result<T, NetworkingError>) -> Void)
    ) -> CancellableRequest

    func performPublisher<T: Decodable & Sendable>(
        request: Request,
        decodeTo decodableObject: T.Type
    ) -> AnyPublisher<T, NetworkingError>
}
