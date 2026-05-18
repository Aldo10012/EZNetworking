import Foundation

public actor DataUploader: Uploadable {
    private nonisolated let tempFileURL: URL?
    private let dataSaver: DataToTempFileSaver
    private let fileUploader: Uploadable

    public init(
        data: Data,
        request: UploadRequest,
        session: NetworkSession = Session(),
        validator: ResponseValidator = DefaultResponseValidator()
    ) throws {
        let dataSaver = DefaultDataToTempFileSaver()
        let tempFileURL = try dataSaver.saveToTempFile(data)
        let fileUploader = FileUploader(
            fileURL: tempFileURL,
            request: request,
            session: session,
            validator: validator
        )
        self.init(
            tempFileURL: tempFileURL,
            dataSaver: dataSaver,
            fileUploader: fileUploader
        )
    }

    init(
        tempFileURL: URL?,
        dataSaver: DataToTempFileSaver,
        fileUploader: Uploadable
    ) {
        self.tempFileURL = tempFileURL
        self.dataSaver = dataSaver
        self.fileUploader = fileUploader
    }

    deinit {
        if let tempFileURL {
            try? dataSaver.clearTempFile(at: tempFileURL)
        }
    }

    public func upload() -> AsyncStream<UploadEvent> {
        let fileUploader = fileUploader
        let dataSaver = dataSaver
        let tempFileURL = tempFileURL

        return AsyncStream { continuation in
            let task = Task {
                var didStartUploading = false
                var shouldClearTempFile = false
                for await event in await fileUploader.upload() {
                    switch event {
                    case .progress:
                        didStartUploading = true
                    case .completed:
                        shouldClearTempFile = true
                    case .failed:
                        if didStartUploading {
                            shouldClearTempFile = true
                        }
                    }
                    continuation.yield(event)
                }
                continuation.finish()
                if shouldClearTempFile, let tempFileURL {
                    try? dataSaver.clearTempFile(at: tempFileURL)
                }
            }
            continuation.onTermination = { @Sendable termination in
                guard case .cancelled = termination else { return }
                task.cancel()
                Task {
                    try? await fileUploader.cancel()
                }
            }
        }
    }

    public func pause() async throws {
        try await fileUploader.pause()
    }

    public func resume() async throws {
        try await fileUploader.resume()
    }

    public func cancel() async throws {
        try await fileUploader.cancel()
    }
}

protocol DataToTempFileSaver: Sendable {
    func saveToTempFile(_ data: Data) throws -> URL
    func clearTempFile(at url: URL) throws
}

struct DefaultDataToTempFileSaver: DataToTempFileSaver {
    func saveToTempFile(_ data: Data) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try data.write(to: url, options: .atomic)
        return url
    }

    func clearTempFile(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}
