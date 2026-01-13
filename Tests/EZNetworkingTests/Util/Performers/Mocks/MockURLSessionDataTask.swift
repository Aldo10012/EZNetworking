import EZNetworking
import Foundation

class MockURLSessionDataTask: URLSessionDataTask {
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
