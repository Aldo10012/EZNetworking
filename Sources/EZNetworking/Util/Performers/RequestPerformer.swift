import Foundation

public protocol RequestPerformable {
    func perform<T: Decodable>(request: URLRequest, decodeTo decodableObject: T.Type, completion: @escaping((Result<T, NetworkingError>)) -> Void)
    func perform(request: URLRequest, completion: @escaping((VoidResult<NetworkingError>) -> Void))
    func downloadFile(url: URL, completion: @escaping((Result<URL, NetworkingError>) -> Void))
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
    public func perform<T: Decodable>(request: URLRequest, decodeTo decodableObject: T.Type, completion: @escaping ((Result<T, NetworkingError>)) -> Void) {
        let dataTask = urlSession.dataTask(with: request) { data, urlResponse, error in
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
        dataTask.resume()
    }
    
    // MARK: perform using Completion Handler without returning Decodable
    public func perform(request: URLRequest, completion: @escaping ((VoidResult<NetworkingError>) -> Void)) {
        let dataTask = urlSession.dataTask(with: request) { data, urlResponse, error in
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
        dataTask.resume()
    }
    
    public func downloadFile(url: URL, completion: @escaping((Result<URL, NetworkingError>) -> Void)) {
        let dataTask = urlSession.downloadTask(with: url) { localURL, response, error in
            do {
                let localURL = try urlResponseValidator.validateDownloadTask(url: localURL, urlResponse: response, error: error)
                completion(.success(localURL))
            } catch let networkError as NetworkingError {
                completion(.failure(networkError))
            } catch {
                completion(.failure(.unknown))
            }
        }
        dataTask.resume()
    }
}
