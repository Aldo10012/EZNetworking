import Foundation
import Combine

public protocol DataUploadable {
    func uploadData(_ data: Data, with request: Request, progress: UploadProgressHandler?) async throws -> Data
    func uploadDataTask(_ data: Data, with request: Request, progress: UploadProgressHandler?, completion: @escaping(UploadCompletionHandler)) -> URLSessionUploadTask?
    func uploadDataPublisher(_ data: Data, with request: Request, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError>
    func uploadDataStream(_ data: Data, with request: Request) -> AsyncStream<UploadStreamEvent>
}
