import Combine
import Foundation

public protocol FileUploadable {
    func uploadFileStream(_ fileURL: URL, with request: Request) -> AsyncStream<UploadStreamEvent>
}
