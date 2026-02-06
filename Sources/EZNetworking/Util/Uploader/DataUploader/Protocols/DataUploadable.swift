import Combine
import Foundation

public protocol DataUploadable {
    func uploadData(_ data: Data, with request: Request, progress: UploadProgressHandler?) async throws -> Data
    func uploadDataStream(_ data: Data, with request: Request) -> AsyncStream<UploadStreamEvent>
    func uploadDataTask(_ data: Data, with request: Request, progress: UploadProgressHandler?, completion: @escaping (UploadCompletionHandler)) -> CancellableRequest
    func uploadDataPublisher(_ data: Data, with request: Request, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError>
}
