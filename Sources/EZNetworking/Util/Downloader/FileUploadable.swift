import Foundation

public protocol FileUploadable {
    func uploadFile(fileURL: URL, to url: URL) async throws -> Data
    func uploadFile(fileURL: URL, to url: URL, completion: @escaping (UploadCompletionHandler)) -> URLSessionUploadTask?
}

public typealias UploadCompletionHandler = (Result<Data?, NetworkingError>) -> Void

public class FileUploader: FileUploadable {
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private var sessionDelegate: SessionDelegate
    private let fileManager: FileManager
    
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

    public func uploadFile(fileURL: URL, to url: URL) async throws -> Data {
        // Check if file exists
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
    
    public func uploadFile(fileURL: URL, to url: URL, completion: @escaping (UploadCompletionHandler)) -> URLSessionUploadTask? {
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
        var body = Data()
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    private func mimeType(for pathExtension: String) -> String {
        return switch pathExtension.lowercased() {
        case "jpg", "jpeg": "image/jpeg"
        case "png": "image/png"
        case "pdf": "application/pdf"
        case "txt": "text/plain"
        case "mp4": "video/mp4"
        case "mov": "video/quicktime"
        case "json": "application/json"
        default: "application/octet-stream"
        }
    }
}
