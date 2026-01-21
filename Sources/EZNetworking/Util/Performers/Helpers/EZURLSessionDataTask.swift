import Foundation

final class EZURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {
    private var task: Task<Void, Never>?
    private let work: @Sendable () async -> Void

    init(work: @escaping @Sendable () async -> Void) {
        self.work = work
        super.init()
    }

    override func resume() {
        guard task == nil else { return } // Prevent double-resume
        task = Task(priority: .high) { await work() }
    }

    override func cancel() {
        task?.cancel()
    }
}
