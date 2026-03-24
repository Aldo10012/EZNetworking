@testable import EZNetworking
import Foundation
import Testing

@Suite("Test URLSessionUploadTaskProtocol")
struct URLSessionUploadTaskProtocolTests {
    @Test("test URLSessionUploadTask conforms to URLSessionUploadTaskProtocol")
    func urlSessionUploadTaskConformance() {
        let session = URLSession(configuration: .default, delegate: SessionDelegate(), delegateQueue: nil)
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test.txt")
        let nativeTask = session.uploadTask(with: request, fromFile: fileURL)
        let proto: URLSessionUploadTaskProtocol = nativeTask
        #expect(proto is URLSessionUploadTask)
        nativeTask.cancel()
        session.invalidateAndCancel()
    }

    @Test("test URLSessionProtocol.uploadTaskInspectable(with:fromFile:) returns URLSessionUploadTaskProtocol")
    func urlSessionProtocolReturnsProtocol() {
        let session: URLSessionProtocol = URLSession(configuration: .default, delegate: SessionDelegate(), delegateQueue: nil)
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test.txt")
        let task = session.uploadTaskInspectable(with: request, fromFile: fileURL)
        #expect(task is URLSessionUploadTask)
        task.cancel()
        (session as? URLSession)?.invalidateAndCancel()
    }
}
