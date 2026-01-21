import Foundation

public final class EZURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {
    private let lock = NSLock()
    private var task: Task<Void, Never>?
    private var isCancelled = false
    private let work: @Sendable () async -> Void

    init(work: @escaping @Sendable () async -> Void) {
        self.work = work
        super.init()
    }

    public override func resume() {
        lock.lock()
        defer { lock.unlock() }

        guard task == nil, !isCancelled else { return } // Prevent double-resume
        task = Task(priority: .high) { await work() }
    }

    public override func cancel() {
        lock.lock()
        defer { lock.unlock() }

        isCancelled = true
        task?.cancel()
    }

    public override func suspend() {
        assertionFailure("""
            suspend() is not supported on async/await-backed tasks.

            This networking library uses Swift Concurrency, which does not
            support pausing in-flight async operations.

            For downloads requiring suspend/resume, use URLSession with
            background configuration directly.
        """)
    }
}
