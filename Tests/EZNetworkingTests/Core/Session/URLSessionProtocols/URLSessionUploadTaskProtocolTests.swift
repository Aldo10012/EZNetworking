@testable import EZNetworking
import Foundation
import Testing

@Suite("Test URLSessionUploadTaskProtocol")
struct URLSessionUploadTaskProtocolTests {
    @Test("test URLSessionUploadTask conforms to URLSessionUploadTaskProtocol")
    func urlSessionUploadTaskConformance() {
        let session = URLSession.shared
        let nativeTask = session.uploadTask(
            with: URLRequest(url: URL(string: "https://example.com")!),
            from: Data()
        )
        let proto: URLSessionUploadTaskProtocol = nativeTask
        #expect(proto is URLSessionUploadTask)
        nativeTask.cancel()
    }

    @Test("test URLSessionProtocol.uploadTaskInspectable(with:fromFile:) returns URLSessionUploadTaskProtocol")
    func urlSessionProtocolReturnsProtocolFromFile() throws {
        let session: URLSessionProtocol = URLSession.shared
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("tmp")
        try Data("payload".utf8).write(to: tempFile)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let task = session.uploadTaskInspectable(
            with: URLRequest(url: URL(string: "https://example.com")!),
            fromFile: tempFile
        )
        #expect(task is URLSessionUploadTask)
        task.cancel()
    }

    // Note: there is intentionally no test that calls
    // `uploadTaskInspectable(withResumeData: Data())` against the real `URLSession`.
    // Unlike `downloadTask(withResumeData:)`, the underlying `uploadTask(withResumeData:)`
    // segfaults when handed empty/invalid resume data instead of returning a failing task.
    // Coverage of this factory comes via the mocked `URLSessionProtocol` used by FileUploader tests.
}
