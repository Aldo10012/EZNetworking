import Foundation
import Combine

public protocol FileUploadable {
    func uploadFile(at fileURL: URL, with request: URLRequest, progress: UploadProgressHandler?) async throws -> Data
    
    func uploadFileTask(_ fileURL: URL, with request: URLRequest, progress: UploadProgressHandler?, completion: @escaping(UploadCompletionHandler)) -> URLSessionUploadTask

    func uploadFilePublisher(_ fileURL: URL, with request: URLRequest, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError>

    func uploadFileStream(_ fileURL: URL, with request: URLRequest) -> AsyncStream<UploadStreamEvent>
}
