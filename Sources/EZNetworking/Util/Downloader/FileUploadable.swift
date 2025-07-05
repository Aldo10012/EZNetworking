import Foundation

public protocol FileUploadable {
    func uploadFile(fileURL: URL, to url: URL, completion: @escaping (UploadCompletionHandler)) -> URLSessionUploadTask?
}

public typealias UploadCompletionHandler = (Result<Data?, NetworkingError>) -> Void

public class FileUploader: FileUploadable {
    private let urlSession: URLSessionTaskProtocol
    private let validator: ResponseValidator
    private var sessionDelegate: SessionDelegate
    
    public convenience init(
        sessionConfiguration: URLSessionConfiguration = .default,
        sessionDelegate: SessionDelegate = SessionDelegate(),
        delegateQueue: OperationQueue? = nil,
        validator: ResponseValidator = ResponseValidatorImpl()
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
        validator: ResponseValidator = ResponseValidatorImpl()
    ) {
        self.init(urlSession: urlSession,
                  validator: validator,
                  sessionDelegate: SessionDelegate())
    }

    internal init(
        urlSession: URLSessionTaskProtocol = URLSession.shared,
        validator: ResponseValidator = ResponseValidatorImpl(),
        sessionDelegate: SessionDelegate = SessionDelegate()
    ) {
        self.urlSession = urlSession
        self.validator = validator
        self.sessionDelegate = sessionDelegate
    }
    
    public func uploadFile(fileURL: URL, to url: URL, completion: @escaping (UploadCompletionHandler)) -> URLSessionUploadTask? {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else { // TODO: Add DI for file manager
            completion(.failure(.internalError(.couldNotParse))) // TODO: add new internal error .fileNotFound
            return nil
        }
        do {
            let (urlRequest, body) = try createRequestAndBody(fileURL: fileURL, serverURL: url)
            
            let uploadTask = urlSession.uploadTask(with: urlRequest, from: body) { [weak self] data, response, error in
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
