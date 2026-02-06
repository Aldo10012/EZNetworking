import Combine
import Foundation

public typealias DownloadProgressHandler = (Double) -> Void
public typealias DownloadCompletionHandler = (Result<URL, NetworkingError>) -> Void

public protocol FileDownloadable {
    func downloadFile(from serverUrl: URL, progress: DownloadProgressHandler?) async throws -> URL
    func downloadFileStream(from serverUrl: URL) -> AsyncStream<DownloadStreamEvent>
    func downloadFileTask(from serverUrl: URL, progress: DownloadProgressHandler?, completion: @escaping (DownloadCompletionHandler)) -> CancellableRequest
    func downloadFilePublisher(from serverUrl: URL, progress: DownloadProgressHandler?) -> AnyPublisher<URL, NetworkingError>
}

public enum DownloadStreamEvent {
    case progress(Double)
    case success(URL)
    case failure(NetworkingError)
}
