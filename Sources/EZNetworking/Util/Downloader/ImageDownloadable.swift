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
    
    public func downloadImage(from url: URL) async throws -> UIImage {
        do {
            let (data, response) = try await urlSession.data(from: url, delegate: nil)
            
            try validator.validateStatus(from: response)
            let validData = try validator.validateData(data)
            
            let image = try getImage(from: validData)
            return image
        } catch let error as NetworkingError {
            throw error
        } catch let error as URLError {
            throw NetworkingError.urlError(error)
        } catch {
            throw NetworkingError.internalError(.unknown)
        }
    }

    @discardableResult
    public func downloadImageTask(url: URL, completion: @escaping((Result<UIImage, NetworkingError>) -> Void)) -> URLSessionDataTask {
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
            } catch let networkError as NetworkingError {
                completion(.failure(networkError))
            } catch {
                completion(.failure(.internalError(.unknown)))
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
}
