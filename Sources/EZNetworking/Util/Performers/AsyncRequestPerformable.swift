//
//  File.swift
//  
//
//  Created by Alberto Dominguez on 7/18/24.
//

import Foundation

public protocol AsyncRequestPerformable {
    func perform<T: Decodable>(request: URLRequest, decodeTo decodableObject: T.Type) async throws -> T
    func perform(request: URLRequest) async throws
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
            try urlResponseValidator.validate(data: data, urlResponse: response, error: nil)
            let result = try requestDecoder.decode(decodableObject.self, from: data)
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
            try urlResponseValidator.validate(data: data, urlResponse: response, error: nil)
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.unknown
        }
    }
}
