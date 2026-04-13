import Foundation

/// Thread-safe wrapper for capturing and mutating a Task reference in `@Sendable` closures.
/// Required for Swift 6 concurrency compliance where direct `var` capture and mutation
/// across concurrent closures is not allowed. Uses `NSLock` for synchronization.
final class TaskBox: @unchecked Sendable {
    private let lock = NSLock()
    private var _task: Task<Void, Never>?

    var task: Task<Void, Never>? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _task
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _task = newValue
        }
    }
}
