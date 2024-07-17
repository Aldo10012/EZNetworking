import Foundation

public protocol RequestPerformable {
    // MARK: perform using Async/Await
    func perform<T: Decodable>(request: URLRequest, decodeTo decodableObject: T.Type) async throws -> T
    
    // MARK: perform using Async Await without returning Decodable
    func perform(request: URLRequest) async throws
    
    // MARK: perform using Completion Handler
    func perform<T: Decodable>( request: URLRequest, decodeTo decodableObject: T.Type, completion: @escaping( (Result<T, NetworkingError>)) -> Void)
    
    // MARK: perform using Completion Handler without returning Decodable
    func perform(request: URLRequest, completion: @escaping((VoidResult<NetworkingError>) -> Void))
}

public struct RequestPerformerImpl: RequestPerformable {
    
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
    
    // MARK: perform using Completion Handler
    public func perform<T: Decodable>(request: URLRequest,
                                      decodeTo decodableObject: T.Type,
                                      completion: @escaping ((Result<T, NetworkingError>)) -> Void
    ) {
        let dataTask = urlSession.dataTask(with: request) { data, urlResponse, error in
            guard let data else {
                completion(.failure(NetworkingError.noData))
                return
            }
            
            do {
                try urlResponseValidator.validate(data: data, urlResponse: urlResponse, error: error)
                let decodedObject = try requestDecoder.decode(decodableObject.self, from: data)
                completion(.success(decodedObject))
            } catch let httpError as NetworkingError {
                completion(.failure(httpError))
                return
            } catch {
                completion(.failure(NetworkingError.unknown))
                return
            }
        }
        dataTask.resume()
    }
    
    // MARK: perform using Completion Handler without returning Decodable
    public func perform(request: URLRequest, completion: @escaping ((VoidResult<NetworkingError>) -> Void)) {
        let dataTask = urlSession.dataTask(with: request) { data, urlResponse, error in
            do {
                try urlResponseValidator.validate(data: data, urlResponse: urlResponse, error: error)
                completion(.success)
            } catch let httpError as NetworkingError {
                completion(.failure(httpError))
                return
            } catch {
                completion(.failure(NetworkingError.unknown))
                return
            }
        }
        dataTask.resume()
    }
}


public enum VoidResult<T: Error> {
    case success
    case failure(T)
}


public protocol URLSessionTaskProtocol {
    func data(for request: URLRequest, delegate: (URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionTaskProtocol {}
