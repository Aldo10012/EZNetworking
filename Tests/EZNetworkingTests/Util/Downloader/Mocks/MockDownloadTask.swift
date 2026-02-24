import EZNetworking
import Foundation

class MockDownloadTask: URLSessionDownloadTaskProtocol {
    var didResume = false
    var didCancel = false
    var mockResumeData: Data?

    func resume() {
        didResume = true
    }

    func cancel() {
        didCancel = true
    }

    func cancelByProducingResumeData() async -> Data? {
        mockResumeData
    }
}
