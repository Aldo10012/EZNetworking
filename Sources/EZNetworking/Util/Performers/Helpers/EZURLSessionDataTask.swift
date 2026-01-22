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
        // Swift Concurrency does not support suspend.
        // This is a no-op to maintain compatibility with URLSessionDataTask API.

        #if DEBUG
        print("""
            Warning: suspend() is not supported on EZURLSessionDataTask.
            This task uses Swift Concurrency, which does not support pausing.
            For suspend/resume, use URLSession with background configuration.
        """)
        #endif
    }
}
