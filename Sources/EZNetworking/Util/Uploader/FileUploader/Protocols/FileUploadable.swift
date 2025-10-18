import Foundation
import Combine

public protocol FileUploadable {
    func uploadFile(at fileURL: URL, with request: Request, progress: UploadProgressHandler?) async throws -> Data
    func uploadFileTask(_ fileURL: URL, with request: Request, progress: UploadProgressHandler?, completion: @escaping(UploadCompletionHandler)) -> URLSessionUploadTask
    func uploadFilePublisher(_ fileURL: URL, with request: Request, progress: UploadProgressHandler?) -> AnyPublisher<Data, NetworkingError>
    func uploadFileStream(_ fileURL: URL, with request: Request) -> AsyncStream<UploadStreamEvent>
}
