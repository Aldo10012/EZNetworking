import Combine
import Foundation

public protocol FileUploadable {
    func uploadFile(_ fileURL: URL, with request: Request, progress: UploadProgressHandler?) async throws -> Data
    func uploadFileStream(_ fileURL: URL, with request: Request) -> AsyncStream<UploadStreamEvent>
    func uploadFileTask(_ fileURL: URL, with request: Request, progress: UploadProgressHandler?, completion: @escaping (UploadCompletionHandler)) -> CancellableRequest?
    func uploadFilePublisher(_ fileURL: URL, with request: Request, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError>
}
