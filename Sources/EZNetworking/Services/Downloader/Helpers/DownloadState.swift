import Foundation

enum DownloadState: Equatable {
    case idle
    case downloading
    case pausing
    case paused(resumeData: Data)
    case completed
    case failed
    case failedButCanResume(resumeData: Data)
    case cancelled
}
