import Combine
import Foundation

public typealias UploadProgressHandler = (Double) -> Void
public typealias UploadCompletionHandler = (Result<Data, NetworkingError>) -> Void

public enum MultipartFormPart {
    case data(name: String, filename: String?, mimeType: String?, data: Data)
}

public protocol DataUploadable {
    func uploadData(_ data: Data, with request: URLRequest, progress: UploadProgressHandler?) async throws -> Data
    
    @discardableResult
    func uploadDataTask(_ data: Data, with request: URLRequest, progress: UploadProgressHandler?, completion: @escaping(UploadCompletionHandler)) -> URLSessionUploadTask

    func uploadDataPublisher(_ data: Data, with request: URLRequest, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError>

    func uploadDataStream(_ data: Data, with request: URLRequest) -> AsyncStream<UploadStreamEvent>
}

public protocol MultipartFormUploadable {
    func uploadMultipart(_ parts: [MultipartFormPart], boundary: String, with request: URLRequest, progress: UploadProgressHandler?) async throws -> Data

    @discardableResult
    func uploadMultipartTask(_ parts: [MultipartFormPart], boundary: String, with request: URLRequest, progress: UploadProgressHandler?, completion: @escaping(UploadCompletionHandler)) -> URLSessionUploadTask

    func uploadMultipartPublisher(_ parts: [MultipartFormPart], boundary: String, with request: URLRequest, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError>

    func uploadMultipartStream(_ parts: [MultipartFormPart], boundary: String, with request: URLRequest) -> AsyncStream<UploadStreamEvent>
}

public protocol FileUploadable {
    func uploadFile(at fileURL: URL, with request: URLRequest, progress: UploadProgressHandler?) async throws -> Data
    
    @discardableResult
    func uploadFileTask(_ fileURL: URL, with request: URLRequest, progress: UploadProgressHandler?, completion: @escaping(UploadCompletionHandler)) -> URLSessionUploadTask

    func uploadFilePublisher(_ fileURL: URL, with request: URLRequest, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError>

    func uploadFileStream(_ fileURL: URL, with request: URLRequest) -> AsyncStream<UploadStreamEvent>
}

public enum UploadStreamEvent {
    case progress(Double)
    case success(Data)
    case failure(NetworkingError)
}


