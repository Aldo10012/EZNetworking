@testable import EZNetworking
import Foundation
import Testing

@Suite("Test URLSessionDownloadTaskProtocol")
struct URLSessionDownloadTaskProtocolTests {
    @Test("test URLSessionDownloadTask conforms to URLSessionDownloadTaskProtocol")
    func urlSessionDownloadTaskConformance() {
        let session = URLSession.shared
        let nativeTask = session.downloadTask(with: URLRequest(url: URL(string: "https://example.com")!))
        let proto: URLSessionDownloadTaskProtocol = nativeTask
        #expect(proto is URLSessionDownloadTask)
        nativeTask.cancel()
    }

    @Test("test URLSessionProtocol.downloadTask(with:) returns URLSessionDownloadTaskProtocol")
    func urlSessionProtocolReturnsProtocol() {
        let session: URLSessionProtocol = URLSession.shared
        let task = session.downloadTaskInspectable(with: URL(string: "https://example.com")!)
        #expect(task is URLSessionDownloadTask)
        task.cancel()
    }

    @Test("test URLSessionProtocol.downloadTask(withResumeData:) returns URLSessionDownloadTaskProtocol")
    func urlSessionProtocolReturnsProtocolWithResumeData() {
        let session: URLSessionProtocol = URLSession.shared
        let task = session.downloadTaskInspectable(withResumeData: Data())
        #expect(task is URLSessionDownloadTask)
        task.cancel()
    }
}
