import Combine
import Foundation

public protocol FileUploadable {
    func uploadFile(_ fileURL: URL, with request: Request, progress: UploadProgressHandler?) async throws -> Data
    func uploadFileTask(_ fileURL: URL, with request: Request, progress: UploadProgressHandler?, completion: @escaping (UploadCompletionHandler)) -> URLSessionUploadTask?
    func uploadFilePublisher(_ fileURL: URL, with request: Request, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError>
    func uploadFileStream(_ fileURL: URL, with request: Request) -> AsyncStream<UploadStreamEvent>
}
