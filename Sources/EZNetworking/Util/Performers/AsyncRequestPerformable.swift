import Foundation
import UIKit

public protocol AsyncRequestPerformable {
    func perform<T: Decodable>(request: URLRequest, decodeTo decodableObject: T.Type) async throws -> T
    func perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T
    func perform(request: URLRequest) async throws
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
    
    // MARK: perform request with Async Await and return Decodable
    public func perform<T: Decodable>(request: URLRequest, decodeTo decodableObject: T.Type) async throws -> T {
        do {
            let (data, response) = try await urlSession.data(for: request, delegate: nil)
            let validData = try urlResponseValidator.validate(data: data, urlResponse: response, error: nil)
            let result = try requestDecoder.decode(decodableObject.self, from: validData)
            return result
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.unknown
        }
    }
    
    // MARK: perform request with Async Await and return Decodable using Request Protocol
    public func perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T {
        do {
            let request = try request.build()
            let (data, response) = try await urlSession.data(for: request, delegate: nil)
            let validData = try urlResponseValidator.validate(data: data, urlResponse: response, error: nil)
            let result = try requestDecoder.decode(decodableObject.self, from: validData)
            return result
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.unknown
        }
    }
    
    // MARK: perform request with Async Await
    public func perform(request: URLRequest) async throws {
        do {
            let (data, response) = try await urlSession.data(for: request, delegate: nil)
            _ = try urlResponseValidator.validate(data: data, urlResponse: response, error: nil)
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.unknown
        }
    }
    
    // MARK: perform request with Async Await using Request protocol
    public func perform(request: Request) async throws {
        do {
            let request = try request.build()
            let (data, response) = try await urlSession.data(for: request, delegate: nil)
            _ = try urlResponseValidator.validate(data: data, urlResponse: response, error: nil)
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.unknown
        }
    }
}
