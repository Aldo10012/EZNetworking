import Combine
import Foundation

public typealias DownloadProgressHandler = (Double) -> Void
public typealias DownloadCompletionHandler = (Result<URL, NetworkingError>) -> Void

public protocol FileDownloadable {
    func downloadFile(from serverUrl: URL, progress: DownloadProgressHandler?) async throws -> URL
    func downloadFileTask(from serverUrl: URL, progress: DownloadProgressHandler?, completion: @escaping (DownloadCompletionHandler)) -> URLSessionDownloadTask
    func downloadFilePublisher(from serverUrl: URL, progress: DownloadProgressHandler?) -> AnyPublisher<URL, NetworkingError>
    func downloadFileStream(from serverUrl: URL) -> AsyncStream<DownloadStreamEvent>
}

public enum DownloadStreamEvent {
    case progress(Double)
    case success(URL)
    case failure(NetworkingError)
}
