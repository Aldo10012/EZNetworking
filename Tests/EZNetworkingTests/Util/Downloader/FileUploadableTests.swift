@testable import EZNetworking
import Foundation
import Testing

@Suite("Test FileUploadableTests")
final class FileUploadableTests {

    // MARK: test Async/Await

    @Test("")
    func testFoobar() async throws {
        let fileURL = URL(string: "file:///tmp/test.pdf")!
        let serverURL = URL(string: "https://example.com/upload")!
        
        let urlSession = MockURLSession(
            url: serverURL,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator()
        let spySpyFileManager = SpyFileManager()
        let sut = FileUploader(urlSession: urlSession, validator: validator, fileManager: spySpyFileManager)
        
        do {
            let localURL = try await sut.uploadFile(fileURL: serverURL, to: serverURL, progress: nil)
            #expect(localURL != nil)
        } catch {
            Issue.record()
        }
    }

    // MARK: test callbacks

    // MARK: helpers

    private func buildResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }
}

private class SpyFileManager: FileManager {
    override func fileExists(atPath path: String) -> Bool {
        return true
    }
}
