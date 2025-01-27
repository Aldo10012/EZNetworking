import Foundation
import UIKit

public protocol RequestPerformable {
    @discardableResult
    func performTask<T: Decodable>(request: Request, decodeTo decodableObject: T.Type, completion: @escaping((Result<T, NetworkingError>) -> Void)) -> URLSessionDataTask?
    @discardableResult
    func performTask(request: Request, completion: @escaping((Result<EmptyResponse, NetworkingError>) -> Void)) -> URLSessionDataTask?
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
    
    // MARK: perform using Completion Handler and Request protocol
    @discardableResult
    public func performTask<T: Decodable>(request: Request, decodeTo decodableObject: T.Type, completion: @escaping ((Result<T, NetworkingError>) -> Void)) -> URLSessionDataTask? {
        return getAndPerformTask(request: request, decodeTo: decodableObject, completion: completion)
    }
    
    // MARK: perform using Completion Handler and Request Protocol without returning Decodable
    @discardableResult
    public func performTask(request: Request, completion: @escaping ((Result<EmptyResponse, NetworkingError>) -> Void)) -> URLSessionDataTask? {
        return getAndPerformTask(request: request, decodeTo: EmptyResponse.self, completion: completion)
    }
    
    @discardableResult
    private func getAndPerformTask<T: Decodable>(
        request: Request,
        decodeTo decodableObject: T.Type,
        completion: @escaping ((Result<T, NetworkingError>) -> Void)
    ) -> URLSessionDataTask? {
        guard let urlRequest = request.urlRequest else {
            completion(.failure(.internalError(.noRequest)))
            return nil
        }
        let task = urlSession.dataTask(with: urlRequest) { data, urlResponse, error in
            do {
                let (validData, validStatus) = try urlResponseValidator.validate(data: data, urlResponse: urlResponse, error: error)
                
                switch validStatus {
                case .success(_):
                    try decode(data: validData, deocdeInto: decodableObject, completion: completion)
                case .redirectionMessage(_):
                    // TODO: properly handle 3xx status codes
                    try decode(data: validData, deocdeInto: decodableObject, completion: completion)
                }
            } catch let httpError as NetworkingError {
                completion(.failure(httpError))
                return
            } catch {
                completion(.failure(NetworkingError.internalError(.unknown)))
                return
            }
        }
        task.resume()
        return task
    }
    
    private func decode<T: Decodable>(data: Data,
                                      deocdeInto decodableObject: T.Type,
                                      completion: @escaping ((Result<T, NetworkingError>) -> Void)) throws {
        let result = try requestDecoder.decode(decodableObject, from: data)
        completion(.success(result))
    }
}
