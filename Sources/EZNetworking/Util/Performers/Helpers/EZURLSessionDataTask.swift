import Foundation

public final class EZURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {
    private var task: Task<Void, Never>?
    private var isCancelled = false  // ADD THIS
    private let workBlock: @Sendable () async -> Void

    init(performOnResume workBlock: @escaping @Sendable () async -> Void) {
        self.workBlock = workBlock
        super.init()
    }

    public override func resume() {
        guard task == nil, !isCancelled else { return } // Prevent double-resume
        task = Task(priority: .high) { await workBlock() }
    }

    public override func cancel() {
        isCancelled = true
        task?.cancel()
    }
}
