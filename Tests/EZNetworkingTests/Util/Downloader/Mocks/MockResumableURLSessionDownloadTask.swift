import EZNetworking
import Foundation

class MockURLSessionDownloadTaskProtocol: URLSessionDownloadTaskProtocol, @unchecked Sendable {
    var didCallResume = false
    var didCallCancel = false
    var resumeDataToReturn: Data?

    func resume() {
        didCallResume = true
    }

    func cancel() {
        didCallCancel = true
    }

    func cancelByProducingResumeData() async -> Data? {
        didCallCancel = true
        return resumeDataToReturn
    }
}
