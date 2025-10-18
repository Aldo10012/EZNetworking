import Foundation

public typealias UploadProgressHandler = (Double) -> Void
public typealias UploadCompletionHandler = (Result<Data, NetworkingError>) -> Void
