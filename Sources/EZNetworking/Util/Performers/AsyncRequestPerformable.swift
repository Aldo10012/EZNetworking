import Foundation
import UIKit

public protocol AsyncRequestPerformable {
    func perform<T: Decodable>(request: URLRequest, decodeTo decodableObject: T.Type) async throws -> T
    func perform(request: URLRequest) async throws
    func downloadFile(with url: URL) async throws -> URL
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
    
    public func downloadFile(with url: URL) async throws -> URL {
        do {
            let (url, urlResponse) = try await urlSession.download(from: url, delegate: nil)
            let localURL = try urlResponseValidator.validateDownloadTask(url: url, urlResponse: urlResponse, error: nil)
            return localURL
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.unknown
        }
    }
    
    public func downloadImage(from url: URL) async throws -> UIImage {
        do {
            let (data, response) = try await urlSession.data(from: url, delegate: nil)
            let validData = try urlResponseValidator.validate(data: data, urlResponse: response, error: nil)
            
            guard let image = UIImage(data: validData) else {
                throw NetworkingError.invalidImageData
            }
            
            return image
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.unknown
        }
    }
}
