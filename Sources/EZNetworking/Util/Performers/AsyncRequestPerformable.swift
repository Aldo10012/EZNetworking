import Foundation
import UIKit

public protocol AsyncRequestPerformable {
    func perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T
    func perform(request: Request) async throws
}

public struct AsyncRequestPerformer: AsyncRequestPerformable {
    
    private let urlSession: URLSessionTaskProtocol
    private let validator: Validator
    private let requestDecoder: RequestDecodable
    
    public init(urlSession: URLSessionTaskProtocol = URLSession.shared,
                validator: Validator = ValidatorImpl(),
                requestDecoder: RequestDecodable = RequestDecoder()) {
        self.urlSession = urlSession
        self.validator = validator
        self.requestDecoder = requestDecoder
    }
    
    // MARK: perform request with Async Await and return Decodable using Request Protocol
    public func perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T {
        return try await performRequest(request: request, decodeTo: decodableObject)
    }
    
    // MARK: perform request with Async Await using Request protocol
    public func perform(request: Request) async throws {
        try await performRequest(request: request, decodeTo: EmptyResponse.self)
    }
    
    @discardableResult
    private func performRequest<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T {
        do {
            let urlRequest = try getURLRequest(from: request)
            let (data, response) = try await urlSession.data(for: urlRequest, delegate: nil)
            
            try validator.validateStatus(from: response)
            let validData = try validator.validateData(data)
            
            let result = try requestDecoder.decode(decodableObject, from: validData)
            return result
        } catch let error as NetworkingError {
            throw error
        } catch let error as URLError {
            throw NetworkingError.urlError(error)
        } catch {
            throw NetworkingError.internalError(.unknown)
        }
    }
    
    private func getURLRequest(from request: Request) throws -> URLRequest {
        guard let urlRequest = request.urlRequest else {
            throw NetworkingError.internalError(.noRequest)
        }
        return urlRequest
    }
}
