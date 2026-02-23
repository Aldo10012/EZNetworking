import Foundation

public actor FileDownloader: FileDownloadable {
    private let url: URL
    private let session: NetworkSession
    private let validator: ResponseValidator

    // MARK: init

    init(
        url: URL,
        session: NetworkSession = Session(),
        validator: ResponseValidator = DefaultResponseValidator()
    ) {
        self.url = url
        self.session = session
        self.validator = validator
    }

    // MARK: - FileDownloadable

    public func downloadFileStream() -> AsyncStream<DownloadEvent> {
        AsyncStream { $0.finish() }
    }

    public func pause() async {}

    public func resume() async {}

    public func cancel() {}
}
