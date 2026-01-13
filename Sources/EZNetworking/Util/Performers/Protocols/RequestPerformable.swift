import Combine
import Foundation

public protocol RequestPerformable {
    func perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T
    func performTask<T: Decodable>(request: Request, decodeTo decodableObject: T.Type, completion: @escaping ((Result<T, NetworkingError>) -> Void)) -> URLSessionDataTask?
    func performPublisher<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) -> AnyPublisher<T, NetworkingError>
}
