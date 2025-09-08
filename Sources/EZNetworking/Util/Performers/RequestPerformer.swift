import Foundation

public protocol RequestPerformable {
    func performTask<T: Decodable>(request: Request, decodeTo decodableObject: T.Type, completion: @escaping((Result<T, NetworkingError>) -> Void)) -> URLSessionDataTask?
}

public struct RequestPerformer: RequestPerformable {
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private let requestDecoder: RequestDecodable
    
    public init(sessionConfiguration: URLSessionConfiguration = .default,
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
    
    // MARK: perform using Completion Handler and Request protocol
    @discardableResult
    public func performTask<T: Decodable>(request: Request, decodeTo decodableObject: T.Type, completion: @escaping ((Result<T, NetworkingError>) -> Void)) -> URLSessionDataTask? {

        guard let urlRequest = request.urlRequest else {
            completion(.failure(.internalError(.noRequest)))
            return nil
        }
        let task = urlSession.dataTask(with: urlRequest) { data, urlResponse, error in
            do {
                try validator.validateNoError(error)
                try validator.validateStatus(from: urlResponse)
                let validData = try validator.validateData(data)
                
                let result = try requestDecoder.decode(decodableObject, from: validData)
                completion(.success(result))
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
}
