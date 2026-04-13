import EZNetworking
import Foundation

class MockDownloadTask: URLSessionDownloadTaskProtocol {
    var didResume = false
    var didCancel = false
    var didCancelWhileProducingResumeData = false
    var mockResumeData: Data?
    var onCancelByProducingResumeData: (@Sendable () async -> Void)?

    func resume() {
        didResume = true
    }

    func cancel() {
        didCancel = true
    }

    func cancelByProducingResumeData() async -> Data? {
        didCancelWhileProducingResumeData = true
        await onCancelByProducingResumeData?()
        return mockResumeData
    }
}
