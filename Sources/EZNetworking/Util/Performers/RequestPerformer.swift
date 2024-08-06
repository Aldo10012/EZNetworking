import Foundation
import UIKit

public protocol RequestPerformable {
    func performTask<T: Decodable>(request: URLRequest, decodeTo decodableObject: T.Type, completion: @escaping((Result<T, NetworkingError>)) -> Void) -> URLSessionDataTask
    func performTask(request: URLRequest, completion: @escaping((VoidResult<NetworkingError>) -> Void)) -> URLSessionDataTask
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
    public func performTask<T: Decodable>(request: URLRequest, decodeTo decodableObject: T.Type, completion: @escaping ((Result<T, NetworkingError>)) -> Void) -> URLSessionDataTask {
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
    public func performTask(request: URLRequest, completion: @escaping ((VoidResult<NetworkingError>) -> Void)) -> URLSessionDataTask {
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
}
