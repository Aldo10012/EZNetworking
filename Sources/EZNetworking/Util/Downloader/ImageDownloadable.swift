import Foundation
import UIKit

public protocol ImageDownloadable {
    func downloadImage(from url: URL) async throws -> UIImage
    func downloadImageTask(url: URL, completion: @escaping((Result<UIImage, NetworkingError>) -> Void)) -> URLSessionDataTask
}

public struct ImageDownloader: ImageDownloadable {
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

    public func downloadImageTask(url: URL, completion: @escaping((Result<UIImage, NetworkingError>) -> Void)) -> URLSessionDataTask {
        return urlSession.dataTask(with: url) { data, response, error in
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
    }
}
