import EZNetworking
import Foundation

class MockUploadTask: URLSessionUploadTaskProtocol {
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

    @available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
    func cancelByProducingResumeData() async -> Data? {
        didCancelWhileProducingResumeData = true
        await onCancelByProducingResumeData?()
        return mockResumeData
    }
}
