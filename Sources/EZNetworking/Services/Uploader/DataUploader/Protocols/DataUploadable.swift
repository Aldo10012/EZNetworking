import Combine
import Foundation

public protocol DataUploadable {
    func uploadDataStream(_ data: Data, with request: Request) -> AsyncStream<UploadStreamEvent>
}
