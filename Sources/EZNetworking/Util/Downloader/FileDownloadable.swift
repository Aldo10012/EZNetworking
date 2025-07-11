import Foundation

public typealias DownloadProgressHandler = (Double) -> Void
public typealias DownloadCompletionHandler = (Result<URL, NetworkingError>) -> Void

public protocol FileDownloadable {
    func downloadFile(with url: URL, progress: DownloadProgressHandler?) async throws -> URL
    @discardableResult
    func downloadFileTask(url: URL, progress: DownloadProgressHandler?, completion: @escaping(DownloadCompletionHandler)) -> URLSessionDownloadTask
}

public class FileDownloader: FileDownloadable {
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private let requestDecoder: RequestDecodable
    private var sessionDelegate: SessionDelegate

    private let fallbackDownloadTaskInterceptor: DownloadTaskInterceptor = DefaultDownloadTaskInterceptor()
    
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
                  requestDecoder: requestDecoder,
                  sessionDelegate: sessionDelegate)
    }

    public convenience init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        validator: ResponseValidator = ResponseValidatorImpl(),
        requestDecoder: RequestDecodable = RequestDecoder()
    ) {
        self.init(urlSession: urlSession,
                  validator: validator,
                  requestDecoder: requestDecoder,
                  sessionDelegate: SessionDelegate())
    }

    internal init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        validator: ResponseValidator = ResponseValidatorImpl(),
        requestDecoder: RequestDecodable = RequestDecoder(),
        sessionDelegate: SessionDelegate = SessionDelegate()
    ) {
        self.urlSession = urlSession
        self.validator = validator
        self.requestDecoder = requestDecoder
        self.sessionDelegate = sessionDelegate
    }
    
    public func downloadFile(with url: URL, progress: DownloadProgressHandler? = nil) async throws -> URL {
        do {
            configureProgressTracking(progress: progress)

            let (localURL, urlResponse) = try await urlSession.download(from: url, delegate: sessionDelegate)
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
    public func downloadFileTask(url: URL, progress: DownloadProgressHandler?, completion: @escaping(DownloadCompletionHandler)) -> URLSessionDownloadTask {
        configureProgressTracking(progress: progress)

        let task = urlSession.downloadTask(with: url) { [weak self] localURL, response, error in
            guard let self else {
                completion(.failure(.internalError(.lostReferenceOfSelf)))
                return
            }
            do {
                try self.validator.validateNoError(error)
                try self.validator.validateStatus(from: response)
                let localURL = try self.validator.validateUrl(localURL)
                
                completion(.success(localURL))
            } catch let networkError as NetworkingError {
                completion(.failure(networkError))
            } catch let error as URLError {
                completion(.failure(.urlError(error)))
            } catch {
                completion(.failure(.internalError(.unknown)))
            }
        }
        task.resume()
        return task
    }

    private func configureProgressTracking(progress: ((Double) -> Void)?) {
        guard let progress else { return }

        if sessionDelegate.downloadTaskInterceptor != nil {
            // Update existing interceptor's progress handler
            sessionDelegate.downloadTaskInterceptor?.progress = progress
        } else {
            // Set up fallback interceptor with progress handler
            fallbackDownloadTaskInterceptor.progress = progress
            sessionDelegate.downloadTaskInterceptor = fallbackDownloadTaskInterceptor
        }
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
