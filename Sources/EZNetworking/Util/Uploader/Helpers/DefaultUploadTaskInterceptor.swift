import Foundation

internal class DefaultUploadTaskInterceptor: UploadTaskInterceptor {
    var progress: (Double) -> Void

    init(progress: @escaping (Double) -> Void = { _ in }) {
        self.progress = progress
    }
}


