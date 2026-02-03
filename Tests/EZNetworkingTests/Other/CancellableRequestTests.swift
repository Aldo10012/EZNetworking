@testable import EZNetworking
import Foundation
import Testing

@Suite("Test CancellableRequest")
final class CancellableRequestTests {
    @Test("test resume callsOnResumeOnce")
    func resumeCallsOnResumeOnce() {
        var resumeCalled = 0
        var cancelCalled = 0

        let request = CancellableRequest(
            onResume: { resumeCalled += 1 },
            onCancel: { cancelCalled += 1 }
        )

        request.resume()
        request.resume() // should not call again

        #expect(resumeCalled == 1, "resume should only call onResume once")
        #expect(cancelCalled == 0, "cancel should not be called yet")
    }

    @Test("test cancel callsOnCancel")
    func cancelCallsOnCancel() {
        var resumeCalled = 0
        var cancelCalled = 0

        let request = CancellableRequest(
            onResume: { resumeCalled += 1 },
            onCancel: { cancelCalled += 1 }
        )

        request.cancel()

        #expect(cancelCalled == 1, "cancel should call onCancel once")
        #expect(resumeCalled == 0, "resume should not be called")
    }

    @Test("test resume then cancel")
    func resumeThenCancel() {
        var resumeCalled = false
        var cancelCalled = false

        let request = CancellableRequest(
            onResume: { resumeCalled = true },
            onCancel: { cancelCalled = true }
        )

        request.resume()
        request.cancel()

        #expect(resumeCalled, "resume should have been called")
        #expect(cancelCalled, "cancel should have been called")
    }

    @Test("test hasStarted flag")
    func hasStartedFlag() {
        let request = CancellableRequest(
            onResume: {},
            onCancel: {}
        )

        #expect(!request.hasStarted)
        request.resume()
        #expect(request.hasStarted)
    }
}
