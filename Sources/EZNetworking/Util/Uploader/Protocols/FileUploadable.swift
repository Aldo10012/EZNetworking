import Combine
import Foundation

public typealias UploadProgressHandler = (Double) -> Void
public typealias UploadCompletionHandler = (Result<Data, NetworkingError>) -> Void

public enum MultipartFormPart {
    case data(name: String, filename: String?, mimeType: String?, data: Data)
}

public protocol FileUploadable {
    // Async/Await
    func uploadData(_ data: Data, with request: URLRequest, progress: UploadProgressHandler?) async throws -> Data
    func uploadFile(at fileURL: URL, with request: URLRequest, progress: UploadProgressHandler?) async throws -> Data
    func uploadMultipart(_ parts: [MultipartFormPart], boundary: String, with request: URLRequest, progress: UploadProgressHandler?) async throws -> Data

    // Completion Handlers
    @discardableResult
    func uploadDataTask(_ data: Data, with request: URLRequest, progress: UploadProgressHandler?, completion: @escaping(UploadCompletionHandler)) -> URLSessionUploadTask
    @discardableResult
    func uploadFileTask(_ fileURL: URL, with request: URLRequest, progress: UploadProgressHandler?, completion: @escaping(UploadCompletionHandler)) -> URLSessionUploadTask
    @discardableResult
    func uploadMultipartTask(_ parts: [MultipartFormPart], boundary: String, with request: URLRequest, progress: UploadProgressHandler?, completion: @escaping(UploadCompletionHandler)) -> URLSessionUploadTask

    // Combine
    func uploadDataPublisher(_ data: Data, with request: URLRequest, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError>
    func uploadFilePublisher(_ fileURL: URL, with request: URLRequest, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError>
    func uploadMultipartPublisher(_ parts: [MultipartFormPart], boundary: String, with request: URLRequest, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError>

    // AsyncStream
    func uploadDataStream(_ data: Data, with request: URLRequest) -> AsyncStream<UploadStreamEvent>
    func uploadFileStream(_ fileURL: URL, with request: URLRequest) -> AsyncStream<UploadStreamEvent>
    func uploadMultipartStream(_ parts: [MultipartFormPart], boundary: String, with request: URLRequest) -> AsyncStream<UploadStreamEvent>
}

public enum UploadStreamEvent {
    case progress(Double)
    case success(Data)
    case failure(NetworkingError)
}


