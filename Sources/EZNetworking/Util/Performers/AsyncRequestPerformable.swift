import Foundation
import UIKit

public protocol AsyncRequestPerformable {
    func perform<T: Decodable>(request: Request, decodeTo decodableObject: T.Type) async throws -> T
    func perform(request: Request) async throws
}

public struct AsyncRequestPerformer: AsyncRequestPerformable {
    
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private let requestDecoder: RequestDecodable
    private let cacheManager: URLCacheManager
    private let etagManager: ETagManager
    
    public init(urlSession: URLSessionTaskProtocol = URLSession.shared,
                validator: ResponseValidator = ResponseValidatorImpl(),
                requestDecoder: RequestDecodable = RequestDecoder(),
                cacheManager: URLCacheManager = URLCacheManagerImpl(),
                etagManager: ETagManager = ETagManagerImpl()) {
        self.urlSession = urlSession
        self.validator = validator
        self.requestDecoder = requestDecoder
        self.cacheManager = cacheManager
        self.etagManager = etagManager
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
            
            let (status, responseHeaders) = try validator.validateStatus(from: response)
            
            if case .redirectionMessage(let redirectStatus) = status {
                if redirectStatus == .notModified {
                    let cachedResponse = try cacheManager.getCachedResponse(for: urlRequest)
                    return try requestDecoder.decode(decodableObject, from: cachedResponse.data)
                } else {
                    throw NetworkingError.redirect(redirectStatus, responseHeaders)
                }
            }
            
            if request.cacheStrategy == .validateWithETag {
                etagManager.updateETag(from: responseHeaders, for: request.etagKey)
            }
            
            let validData = try validator.validateData(data)
            return try requestDecoder.decode(decodableObject, from: validData)
        } catch let error as NetworkingError {
            throw error
        } catch let error as URLError {
            throw NetworkingError.urlError(error)
        } catch {
            throw NetworkingError.internalError(.unknown)
        }
    }
    
    private func getURLRequest(from request: Request) throws -> URLRequest {
        var request = request
        if request.cacheStrategy == .validateWithETag {
            addETagToRequestHeader(&request)
        }
        guard let urlRequest = request.urlRequest else {
            throw NetworkingError.internalError(.noRequest)
        }
        return urlRequest
    }
    
    private func addETagToRequestHeader(_ request: inout Request) {
        if let etag = etagManager.getETag(for: request.etagKey) {
            if request.additionalHeaders == nil {
                request.additionalHeaders = []
            }
            request.additionalHeaders?.append(.ifNoneMatch(etag))
        }
    }
}
