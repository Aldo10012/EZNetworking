import Foundation

public final class EZURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {
    private let lock = NSLock()
    private var task: Task<Void, Never>?
    private var isCancelled = false
    private let workBlock: @Sendable () async -> Void

    init(performOnResume workBlock: @escaping @Sendable () async -> Void) {
        self.workBlock = workBlock
        super.init()
    }

    public override func resume() {
        lock.lock()
        defer { lock.unlock() }

        guard task == nil, !isCancelled else { return } // Prevent double-resume
        task = Task(priority: .high) { await workBlock() }
    }

    public override func cancel() {
        lock.lock()
        defer { lock.unlock() }

        isCancelled = true
        task?.cancel()
    }
}
