import Foundation

enum UploadState: Equatable {
    case idle
    case uploading
    case pausing
    case paused(resumeData: Data)
    case completed
    case failed
    case failedButCanResume(resumeData: Data)
    case cancelled

    var resumeData: Data? {
        switch self {
        case let .paused(data):
            data
        case let .failedButCanResume(data):
            data
        default:
            nil
        }
    }
}
