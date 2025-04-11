import Foundation

public protocol FileDownloadable {
    func downloadFile(with url: URL) async throws -> URL
    func downloadFile(with url: URL, progress: ((Double) -> Void)?) async throws -> URL
    @discardableResult
    func downloadFileTask(url: URL,completion: @escaping((Result<URL, NetworkingError>) -> Void)) -> URLSessionDownloadTask
    @discardableResult
    func downloadFileTask(url: URL, progress: ((Double) -> Void)?, completion: @escaping((Result<URL, NetworkingError>) -> Void)) -> URLSessionDownloadTask
}

public class FileDownloader: FileDownloadable {
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private let requestDecoder: RequestDecodable
    private var downloadTaskInterceptor: DownloadTaskInterceptor?
    
    public convenience init(
        sessionConfiguration: URLSessionConfiguration = .default,
        sessionDelegate: SessionDelegate = SessionDelegate(),
        delegateQueue: OperationQueue? = nil,
        validator: ResponseValidator = ResponseValidatorImpl(),
        requestDecoder: RequestDecodable = RequestDecoder()
    ) {
        let urlSession = URLSession(configuration: sessionConfiguration,
                                    delegate: sessionDelegate,
                                    delegateQueue: delegateQueue)
        self.init(urlSession: urlSession,
                  validator: validator,
                  requestDecoder: requestDecoder)
        self.downloadTaskInterceptor = sessionDelegate.downloadTaskInterceptor
    }

    public init(urlSession: URLSessionTaskProtocol = URLSession.shared,
                validator: ResponseValidator = ResponseValidatorImpl(),
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
    
    public func downloadFile(with url: URL, progress: ((Double) -> Void)? = nil) async throws -> URL {
        do {
            if let progress = progress {
                if downloadTaskInterceptor != nil { // user is using custom DownloadTaskInterceptor
                    downloadTaskInterceptor?.progress = progress
                } else {
                    downloadTaskInterceptor = DefaultDownloadTaskInterceptor(progress: progress)
                }
            }
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
        let task = urlSession.downloadTask(with: url) { [weak self] localURL, response, error in
            guard let self else { return }
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
    
    public func downloadFileTask(url: URL, progress: ((Double) -> Void)?, completion: @escaping ((Result<URL, NetworkingError>) -> Void)) -> URLSessionDownloadTask {
        if let progress = progress {
            if downloadTaskInterceptor != nil { // user is using custom DownloadTaskInterceptor
                downloadTaskInterceptor?.progress = progress
            } else {
                downloadTaskInterceptor = DefaultDownloadTaskInterceptor(progress: progress)
            }
        }
        let task = urlSession.downloadTask(with: url) { [weak self] localURL, response, error in
            guard let self else { return }
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

/// Default implementation of DownloadTaskInterceptor
private class DefaultDownloadTaskInterceptor: DownloadTaskInterceptor {
    var progress: (Double) -> Void
    
    init(progress: @escaping (Double) -> Void = { _ in }) {
        self.progress = progress
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        progress(1.0)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let currentProgress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progress(currentProgress)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        let currentProgress = Double(fileOffset) / Double(expectedTotalBytes)
        progress(currentProgress)
    }
}
