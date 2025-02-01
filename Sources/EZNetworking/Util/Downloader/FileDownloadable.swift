import Foundation

public protocol FileDownloadable {
    func downloadFile(with url: URL) async throws -> URL
    @discardableResult
    func downloadFileTask(url: URL, completion: @escaping((Result<URL, NetworkingError>) -> Void)) -> URLSessionDownloadTask
}

public struct FileDownloader: FileDownloadable {
    
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
    
    public func downloadFile(with url: URL) async throws -> URL {
        do {
            let (url, urlResponse) = try await urlSession.download(from: url, delegate: nil)
            
            try urlResponseValidator.validateStatus(from: urlResponse)
            let localURL = try urlResponseValidator.validateUrl(url)
            return localURL
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
                try urlResponseValidator.validateNoError(error)
                try urlResponseValidator.validateStatus(from: response)
                let localURL = try urlResponseValidator.validateUrl(localURL)
                
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
