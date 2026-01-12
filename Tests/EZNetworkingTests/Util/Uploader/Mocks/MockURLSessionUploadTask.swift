import EZNetworking
import Foundation

class MockURLSessionUploadTask: URLSessionUploadTask {
    private let closure: () -> Void
    var didCancel = false

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }

    override func cancel() {
        didCancel = true
    }
}
