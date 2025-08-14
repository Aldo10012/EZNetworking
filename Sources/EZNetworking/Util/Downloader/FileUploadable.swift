import Foundation

public protocol FileUploadable {
    func uploadFile(fileURL: URL, to url: URL, progress: UploadProgressHandler?) async throws -> Data
    func uploadFile(fileURL: URL, to url: URL, progress: UploadProgressHandler?, completion: @escaping (UploadCompletionHandler)) -> URLSessionUploadTask?
}

public typealias UploadCompletionHandler = (Result<Data?, NetworkingError>) -> Void
public typealias UploadProgressHandler = (Double) -> Void

public class FileUploader: FileUploadable {
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private var sessionDelegate: SessionDelegate
    private let fileManager: FileManager

    private let fallbackUploadTaskInterceptor: UploadTaskInterceptor = DefaultUploadTaskInterceptor()

    public convenience init(
        sessionConfiguration: URLSessionConfiguration = .default,
        sessionDelegate: SessionDelegate = SessionDelegate(),
        delegateQueue: OperationQueue? = nil,
        validator: ResponseValidator = ResponseValidatorImpl(),
        fileManager: FileManager = FileManager.default
    ) {
        let urlSession = URLSession(configuration: sessionConfiguration,
                                    delegate: sessionDelegate,
                                    delegateQueue: delegateQueue)
        self.init(urlSession: urlSession,
                  validator: validator,
                  sessionDelegate: sessionDelegate)
    }

    public convenience init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        validator: ResponseValidator = ResponseValidatorImpl(),
        fileManager: FileManager = FileManager.default
    ) {
        self.init(urlSession: urlSession,
                  validator: validator,
                  sessionDelegate: SessionDelegate(),
                  fileManager: fileManager)
    }

    internal init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        validator: ResponseValidator = ResponseValidatorImpl(),
        sessionDelegate: SessionDelegate = SessionDelegate(),
        fileManager: FileManager = FileManager.default
    ) {
        self.urlSession = urlSession
        self.validator = validator
        self.sessionDelegate = sessionDelegate
        self.fileManager = fileManager
    }

    public func uploadFile(fileURL: URL, to url: URL, progress: UploadProgressHandler?) async throws -> Data {
        configureProgressTracking(progress: progress)
        
        do {
            try validateFileExists(fileURL: fileURL)
            let (urlRequest, bodyData) = try createRequestAndBody(fileURL: fileURL, serverURL: url)
            
            let (data, response) = try await urlSession.upload(for: urlRequest, from: bodyData, delegate: nil)
            try self.validator.validateStatus(from: response)
            let validData = try validator.validateData(data)
            return validData
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.internalError(.unknown)
        }
    }
    
    public func uploadFile(fileURL: URL, to url: URL, progress: UploadProgressHandler?, completion: @escaping (UploadCompletionHandler)) -> URLSessionUploadTask? {
        configureProgressTracking(progress: progress)
        
        do {
            try validateFileExists(fileURL: fileURL)
            let (urlRequest, bodyData) = try createRequestAndBody(fileURL: fileURL, serverURL: url)
            
            let uploadTask = urlSession.uploadTask(with: urlRequest, from: bodyData) { [weak self] data, response, error in
                guard let self else {
                    completion(.failure(.internalError(.lostReferenceOfSelf)))
                    return
                }
                do {
                    try self.validator.validateNoError(error)
                    try self.validator.validateStatus(from: response)
                    let validData = try validator.validateData(data)
                    
                    completion(.success(validData))
                } catch let networkError as NetworkingError {
                    completion(.failure(networkError))
                } catch let error as URLError {
                    completion(.failure(.urlError(error)))
                } catch {
                    completion(.failure(.internalError(.unknown)))
                }
            }
            uploadTask.resume()
            return uploadTask
        } catch let error as NetworkingError {
            completion(.failure(error))
            return nil
        } catch {
            completion(.failure(.internalError(.unknown)))
            return nil
        }
    }
    
    // MARK: - Helper Methods

    private func validateFileExists(fileURL: URL) throws {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw NetworkingError.internalError(.fileNotFound)
        }
    }

    private func createRequestAndBody(fileURL: URL, serverURL url: URL) throws -> (URLRequest, Data) {
        // Create multipart form data request
        let boundary = UUID().uuidString
        let request = RequestBuilderImpl()
            .setHttpMethod(.POST)
            .setBaseUrl(url.absoluteString)
            .setHeaders([
                .contentType(.custon("multipart/form-data; boundary=\(boundary)"))
            ])
            .setCachePolicy(.reloadIgnoringLocalCacheData)
            .build()

        guard let urlRequest = request?.urlRequest else {
            throw NetworkingError.internalError(.noRequest)
        }
        
        do {
            // Read file data
            let fileData = try Data(contentsOf: fileURL)
            let fileName = fileURL.lastPathComponent
            let mimeType = mimeType(for: fileURL.pathExtension)
            
            // Create multipart body
            let body = createMultipartBody(boundary: boundary, fileData: fileData, fileName: fileName, mimeType: mimeType)
            return (urlRequest, body)
        } catch {
            throw NetworkingError.internalError(.noData)
        }
    }
    
    private func createMultipartBody(boundary: String, fileData: Data, fileName: String, mimeType: String) -> Data {
        MultipartBodyBuilder.createMultipartBody(boundary: boundary, fileData: fileData, fileName: fileName, mimeType: mimeType)
    }
    
    private func mimeType(for pathExtension: String) -> String {
        MimeType.mimeType(for: pathExtension)
    }
    
    private func configureProgressTracking(progress: ((Double) -> Void)?) {
        guard let progress else { return }

        if sessionDelegate.uploadTaskInterceptor != nil {
            // Update existing interceptor's progress handler
            sessionDelegate.uploadTaskInterceptor?.progress = progress
        } else {
            // Set up fallback interceptor with progress handler
            fallbackUploadTaskInterceptor.progress = progress
            sessionDelegate.uploadTaskInterceptor = fallbackUploadTaskInterceptor
        }
    }
}

private class DefaultUploadTaskInterceptor: UploadTaskInterceptor {
    var progress: (Double) -> Void
    
    init(progress: @escaping (Double) -> Void = { _ in }) {
        self.progress = progress
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let currentProgress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        progress(currentProgress)
    }
}
