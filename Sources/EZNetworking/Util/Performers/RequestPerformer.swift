import Foundation
import UIKit

public protocol RequestPerformable {
    func perform<T: Decodable>(request: URLRequest, decodeTo decodableObject: T.Type, completion: @escaping((Result<T, NetworkingError>)) -> Void) -> URLSessionDataTask
    func perform(request: URLRequest, completion: @escaping((VoidResult<NetworkingError>) -> Void)) -> URLSessionDataTask
    func downloadFile(url: URL, completion: @escaping((Result<URL, NetworkingError>) -> Void)) -> URLSessionDownloadTask
    func downloadImage(url: URL, completion: @escaping((Result<UIImage, NetworkingError>) -> Void))
}

public struct RequestPerformer: RequestPerformable {
    
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
    
    // MARK: perform using Completion Handler
    public func perform<T: Decodable>(request: URLRequest, decodeTo decodableObject: T.Type, completion: @escaping ((Result<T, NetworkingError>)) -> Void) -> URLSessionDataTask {
        return urlSession.dataTask(with: request) { data, urlResponse, error in
            do {
                let validData = try urlResponseValidator.validate(data: data, urlResponse: urlResponse, error: error)
                let decodedObject = try requestDecoder.decode(decodableObject.self, from: validData)
                completion(.success(decodedObject))
            } catch let httpError as NetworkingError {
                completion(.failure(httpError))
                return
            } catch {
                completion(.failure(NetworkingError.unknown))
                return
            }
        }
    }
    
    // MARK: perform using Completion Handler without returning Decodable
    public func perform(request: URLRequest, completion: @escaping ((VoidResult<NetworkingError>) -> Void)) -> URLSessionDataTask {
        return urlSession.dataTask(with: request) { data, urlResponse, error in
            do {
                _ = try urlResponseValidator.validate(data: data, urlResponse: urlResponse, error: error)
                completion(.success)
            } catch let httpError as NetworkingError {
                completion(.failure(httpError))
                return
            } catch {
                completion(.failure(NetworkingError.unknown))
                return
            }
        }
    }
    
    public func downloadFile(url: URL, completion: @escaping((Result<URL, NetworkingError>) -> Void)) -> URLSessionDownloadTask {
        return urlSession.downloadTask(with: url) { localURL, response, error in
            do {
                let localURL = try urlResponseValidator.validateDownloadTask(url: localURL, urlResponse: response, error: error)
                completion(.success(localURL))
            } catch let networkError as NetworkingError {
                completion(.failure(networkError))
            } catch {
                completion(.failure(.unknown))
            }
        }
    }
    
    public func downloadImage(url: URL, completion: @escaping((Result<UIImage, NetworkingError>) -> Void)) {
        let dataTask = urlSession.dataTask(with: url) { data, response, error in
            do {
                let validData = try self.urlResponseValidator.validate(data: data, urlResponse: response, error: error)
                guard let image = UIImage(data: validData) else {
                    throw NetworkingError.invalidImageData
                }                
                completion(.success(image))
            } catch let networkError as NetworkingError {
                completion(.failure(networkError))
            } catch {
                completion(.failure(.unknown))
            }
        }
        dataTask.resume()
    }
}
