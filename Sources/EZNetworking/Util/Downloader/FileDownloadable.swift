import Foundation

public protocol FileDownloadable {
    func downloadFile(with url: URL) async throws -> URL
    @discardableResult
    func downloadFileTask(url: URL, completion: @escaping((Result<URL, NetworkingError>) -> Void)) -> URLSessionDownloadTask
}

public struct FileDownloader: FileDownloadable {
    
    private let urlSession: URLSessionTaskProtocol
    private let validator: RequestValidator
    private let requestDecoder: RequestDecodable
    
    public init(urlSession: URLSessionTaskProtocol = URLSession.shared,
                validator: RequestValidator = RequestValidatorImpl(),
                requestDecoder: RequestDecodable = RequestDecoder()) {
        self.urlSession = urlSession
        self.validator = validator
        self.requestDecoder = requestDecoder
    }
    
    public func downloadFile(with url: URL) async throws -> URL {
        do {
            let (localURL, urlResponse) = try await urlSession.download(from: url, delegate: nil)
            
            try validator.validateStatus(from: urlResponse)
            let unwrappedLocalURL = try validator.validateUrl(localURL)
            return unwrappedLocalURL
        } catch let error as NetworkingError {
            throw error
        } catch let error as URLError {
            throw NetworkingError.urlError(error)
        } catch {
            throw NetworkingError.internalError(.unknown)
        }
    }

    @discardableResult
    public func downloadFileTask(url: URL, completion: @escaping((Result<URL, NetworkingError>) -> Void)) -> URLSessionDownloadTask {
        let task = urlSession.downloadTask(with: url) { localURL, response, error in
            do {
                try validator.validateNoError(error)
                try validator.validateStatus(from: response)
                let localURL = try validator.validateUrl(localURL)
                
                completion(.success(localURL))
            } catch let networkError as NetworkingError {
                completion(.failure(networkError))
            } catch {
                completion(.failure(.internalError(.unknown)))
            }
        }
        task.resume()
        return task
    }
}
