import Foundation

/// Protocol for intercepting upload tasks specifically.
public protocol UploadTaskInterceptor: AnyObject {
    /// Track the progress of the upload process
    var progress: (Double) -> Void { get set }
}

// TODO: update