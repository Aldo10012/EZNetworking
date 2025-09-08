import Foundation
import UIKit

public protocol ImageDownloadable {
    func downloadImage(from url: URL) async throws -> UIImage
    @discardableResult
    func downloadImageTask(url: URL, completion: @escaping((Result<UIImage, NetworkingError>) -> Void)) -> URLSessionDataTask
}

public class ImageDownloader: ImageDownloadable {
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private let requestDecoder: RequestDecodable

    // MARK: init

    public convenience init(sessionConfiguration: URLSessionConfiguration = .default,
                sessionDelegate: SessionDelegate = SessionDelegate(),
                delegateQueue: OperationQueue? = nil,
                validator: ResponseValidator = ResponseValidatorImpl(),
                requestDecoder: RequestDecodable = RequestDecoder()) {
        let urlSession = URLSession(configuration: sessionConfiguration,
                                    delegate: sessionDelegate,
                                    delegateQueue: delegateQueue)
        self.init(urlSession: urlSession,
                  validator: validator,
                  requestDecoder: requestDecoder)
    }
    
    public init(urlSession: URLSessionTaskProtocol = URLSession.shared,
                validator: ResponseValidator = ResponseValidatorImpl(),
                requestDecoder: RequestDecodable = RequestDecoder()) {
        self.urlSession = urlSession
        self.validator = validator
        self.requestDecoder = requestDecoder
    }

    // MARK: Async Await
    public func downloadImage(from url: URL) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            _downloadImageTask(url: url) { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: Completion Handler
    @discardableResult
    public func downloadImageTask(url: URL, completion: @escaping((Result<UIImage, NetworkingError>) -> Void)) -> URLSessionDataTask {
        return _downloadImageTask(url: url, completion: completion)
    }

    // MARK: - Core
    
    @discardableResult
    private func _downloadImageTask(url: URL, completion: @escaping((Result<UIImage, NetworkingError>) -> Void)) -> URLSessionDataTask {
        let task = urlSession.dataTask(with: url) { [weak self] data, response, error in
            guard let self else {
                completion(.failure(.internalError(.lostReferenceOfSelf)))
                return
            }
            do {
                try self.validator.validateNoError(error)
                try self.validator.validateStatus(from: response)
                let validData = try self.validator.validateData(data)
                
                let image = try self.getImage(from: validData)
                completion(.success(image))
            } catch {
                completion(.failure(mapError(error)))
            }
        }
        task.resume()
        return task
    }
    
    internal func getImage(from data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw NetworkingError.internalError(.invalidImageData)
        }
        return image
    }

    private func mapError(_ error: Error) -> NetworkingError {
        if let networkError = error as? NetworkingError { return networkError }
        if let urlError = error as? URLError { return .urlError(urlError) }
        return .internalError(.unknown)
    }
}
