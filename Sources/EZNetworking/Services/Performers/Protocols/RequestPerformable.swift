import Foundation

public protocol RequestPerformable {
    func perform<T: Decodable & Sendable>(
        request: Request,
        decodeTo decodableObject: T.Type
    ) async throws -> T
}
