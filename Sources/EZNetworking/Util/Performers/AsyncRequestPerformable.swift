import Foundation
import UIKit

public protocol AsyncRequestPerformable {
    func perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T
    func perform(request: Request) async throws
}

public struct AsyncRequestPerformer: AsyncRequestPerformable {
    
    private let urlSession: URLSessionTaskProtocol
    private let urlResponseValidator: URLResponseValidator
    private let requestDecoder: RequestDecodable
    
    public init(urlSession: URLSessionTaskProtocol = URLSession.shared,
                urlResponseValidator: URLResponseValidator = URLResponseValidatorImpl(),
                requestDecoder: RequestDecodable = RequestDecoder()) {
        self.urlSession = urlSession
        self.urlResponseValidator = urlResponseValidator
        self.requestDecoder = requestDecoder
    }
    
    // MARK: perform request with Async Await and return Decodable using Request Protocol
    public func perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T {
        do {
            let urlRequest = try getURLRequest(from: request)
            let (data, response) = try await urlSession.data(for: urlRequest, delegate: nil)
            let validData = try urlResponseValidator.validate(data: data, urlResponse: response, error: nil)
            let result = try requestDecoder.decode(decodableObject.self, from: validData)
            return result
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.internalError(.unknown)
        }
    }
    
    // MARK: perform request with Async Await using Request protocol
    public func perform(request: Request) async throws {
        do {
            let urlRequest = try getURLRequest(from: request)
            let (data, response) = try await urlSession.data(for: urlRequest, delegate: nil)
            _ = try urlResponseValidator.validate(data: data, urlResponse: response, error: nil)
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.internalError(.unknown)
        }
    }
    
    private func getURLRequest(from request: Request) throws -> URLRequest {
        guard let urlRequest = request.urlRequest() else {
            throw NetworkingError.internalError(.noRequest)
        }
        return urlRequest
    }
}
