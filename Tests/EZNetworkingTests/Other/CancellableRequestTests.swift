@testable import EZNetworking
import Foundation
import Testing

@Suite("Test CancellableRequest")
final class CancellableRequestTests {
    @Test("test resume callsOnResumeOnce")
    func resumeCallsOnResumeOnce() {
        let resumeCalled = Counter()
        let cancelCalled = Counter()

        let request = CancellableRequest(
            onResume: { resumeCalled.increment() },
            onCancel: { cancelCalled.increment() }
        )

        request.resume()
        request.resume() // should not call again

        #expect(resumeCalled.value == 1, "resume should only call onResume once")
        #expect(cancelCalled.value == 0, "cancel should not be called yet")
    }

    @Test("test cancel callsOnCancel")
    func cancelCallsOnCancel() {
        let resumeCalled = Counter()
        let cancelCalled = Counter()

        let request = CancellableRequest(
            onResume: { resumeCalled.increment() },
            onCancel: { cancelCalled.increment() }
        )

        request.cancel()

        #expect(cancelCalled.value == 1, "cancel should call onCancel once")
        #expect(resumeCalled.value == 0, "resume should not be called")
    }

    @Test("test resume then cancel")
    func resumeThenCancel() {
        let resumeCalled = Flag()
        let cancelCalled = Flag()

        let request = CancellableRequest(
            onResume: { resumeCalled.set() },
            onCancel: { cancelCalled.set() }
        )

        request.resume()
        request.cancel()

        #expect(resumeCalled.isSet, "resume should have been called")
        #expect(cancelCalled.isSet, "cancel should have been called")
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

// MARK: - Test Helpers

/// Thread-safe counter for testing @Sendable closures
private final class Counter: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Int = 0

    var value: Int {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    func increment() {
        lock.lock()
        defer { lock.unlock() }
        _value += 1
    }
}

/// Thread-safe boolean flag for testing @Sendable closures
private final class Flag: @unchecked Sendable {
    private let lock = NSLock()
    private var _isSet: Bool = false

    var isSet: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isSet
    }

    func set() {
        lock.lock()
        defer { lock.unlock() }
        _isSet = true
    }
}
