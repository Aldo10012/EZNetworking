import Foundation
import UIKit

public protocol ImageDownloadable {
    func downloadImage(from url: URL) async throws -> UIImage
    @discardableResult
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
            let image = try getImage(from: validData)
            return image
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.unknown
        }
    }

    @discardableResult
    public func downloadImageTask(url: URL, completion: @escaping((Result<UIImage, NetworkingError>) -> Void)) -> URLSessionDataTask {
        let task = urlSession.dataTask(with: url) { data, response, error in
            do {
                let validData = try self.urlResponseValidator.validate(data: data, urlResponse: response, error: error)
                let image = try getImage(from: validData)
                completion(.success(image))
            } catch let networkError as NetworkingError {
                completion(.failure(networkError))
            } catch {
                completion(.failure(.unknown))
            }
        }
        task.resume()
        return task
    }
    
    private func getImage(from data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw NetworkingError.invalidImageData
        }
        return image
    }
}
