import Foundation

public class CancellableRequest {
    private let onResume: () -> Void
    private let onCancel: () -> Void
    private(set) var hasStarted = false

    init(
        onResume: @escaping @Sendable (() -> Void),
        onCancel: @escaping @Sendable (() -> Void)
    ) {
        self.onResume = onResume
        self.onCancel = onCancel
    }

    public func resume() {
        guard !hasStarted else { return }
        hasStarted = true
        onResume()
    }
    public func cancel() {
        onCancel()
    }
}
