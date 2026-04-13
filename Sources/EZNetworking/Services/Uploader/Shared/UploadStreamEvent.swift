import Foundation

public enum UploadStreamEvent {
    case progress(Double)
    case success(Data)
    case failure(NetworkingError)
}
