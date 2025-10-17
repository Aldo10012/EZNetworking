import Foundation
import Combine

public protocol MultipartFormUploadable {
    func uploadMultipart(_ parts: [MultipartFormPart], boundary: String, with request: URLRequest, progress: UploadProgressHandler?) async throws -> Data

    @discardableResult
    func uploadMultipartTask(_ parts: [MultipartFormPart], boundary: String, with request: URLRequest, progress: UploadProgressHandler?, completion: @escaping(UploadCompletionHandler)) -> URLSessionUploadTask

    func uploadMultipartPublisher(_ parts: [MultipartFormPart], boundary: String, with request: URLRequest, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError>

    func uploadMultipartStream(_ parts: [MultipartFormPart], boundary: String, with request: URLRequest) -> AsyncStream<UploadStreamEvent>
}

public enum MultipartFormPart {
    case data(name: String, filename: String?, mimeType: String?, data: Data)
}
