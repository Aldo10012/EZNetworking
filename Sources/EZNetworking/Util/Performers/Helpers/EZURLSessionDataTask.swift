import Foundation

final class EZURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {
    private var task: Task<Void, Never>?
    private let workBlock: @Sendable () async -> Void

    init(performOnResume workBlock: @escaping @Sendable () async -> Void) {
        self.workBlock = workBlock
        super.init()
    }

    override func resume() {
        guard task == nil else { return } // Prevent double-resume
        task = Task(priority: .high) { await workBlock() }
    }

    override func cancel() {
        task?.cancel()
    }
}
