import Combine
import Foundation

public typealias UploadProgressHandler = (Double) -> Void
public typealias UploadCompletionHandler = (Result<Data, NetworkingError>) -> Void

public enum MultipartFormPart {
    case data(name: String, filename: String?, mimeType: String?, data: Data)
}

public enum UploadStreamEvent {
    case progress(Double)
    case success(Data)
    case failure(NetworkingError)
}
