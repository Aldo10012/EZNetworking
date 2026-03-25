@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DownloadDestination")
final class DownloadDestinationTests {
    // MARK: - .temporary

    @Test("test temporary copies file to temp directory")
    func temporaryCopiesFileToTempDirectory() throws {
        let tempFile = createTempFile(content: "hello", extension: "txt")
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let destination = DownloadDestination.temporary
        let result = try destination.moveFile(from: tempFile)
        defer { try? FileManager.default.removeItem(at: result) }

        #expect(result.pathExtension == "txt")
        #expect(result.deletingLastPathComponent().path == FileManager.default.temporaryDirectory.path)
        #expect(FileManager.default.fileExists(atPath: result.path))
        // Original should still exist (copy, not move)
        #expect(FileManager.default.fileExists(atPath: tempFile.path))
    }

    @Test("test temporary fails when source file does not exist")
    func temporaryFailsWhenSourceDoesNotExist() {
        let fakeURL = URL(fileURLWithPath: "/tmp/nonexistent_\(UUID().uuidString).txt")
        let destination = DownloadDestination.temporary

        #expect(throws: (any Error).self) {
            try destination.moveFile(from: fakeURL)
        }
    }

    // MARK: - .documents

    @Test("test documents moves file to documents directory")
    func documentsMovesFileToDocumentsDirectory() throws {
        let tempFile = createTempFile(content: "hello", extension: "pdf")
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let filename = "test_\(UUID().uuidString).pdf"
        let destination = DownloadDestination.documents(filename: filename)
        let result = try destination.moveFile(from: tempFile)
        defer { try? FileManager.default.removeItem(at: result) }

        #expect(result.lastPathComponent == filename)
        #expect(FileManager.default.fileExists(atPath: result.path))
        // Original should be gone (move, not copy)
        #expect(!FileManager.default.fileExists(atPath: tempFile.path))
    }

    @Test("test documents overwrites existing file at destination")
    func documentsOverwritesExistingFile() throws {
        let filename = "test_\(UUID().uuidString).txt"
        let documentsURL = try FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        )
        let existingFile = documentsURL.appendingPathComponent(filename)
        try "old content".data(using: .utf8)!.write(to: existingFile)
        defer { try? FileManager.default.removeItem(at: existingFile) }

        let tempFile = createTempFile(content: "new content", extension: "txt")
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let destination = DownloadDestination.documents(filename: filename)
        let result = try destination.moveFile(from: tempFile)

        let content = try String(contentsOf: result, encoding: .utf8)
        #expect(content == "new content")
    }

    @Test("test documents fails when source file does not exist")
    func documentsFailsWhenSourceDoesNotExist() {
        let fakeURL = URL(fileURLWithPath: "/tmp/nonexistent_\(UUID().uuidString).txt")
        let destination = DownloadDestination.documents(filename: "output.txt")

        #expect(throws: (any Error).self) {
            try destination.moveFile(from: fakeURL)
        }
    }

    // MARK: - .custom

    @Test("test custom uses provided handler")
    func customUsesProvidedHandler() throws {
        let tempFile = createTempFile(content: "data", extension: "bin")
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let customDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("custom_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: customDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: customDir) }

        let destination = DownloadDestination.custom { url in
            let dest = customDir.appendingPathComponent("moved.bin")
            try FileManager.default.moveItem(at: url, to: dest)
            return dest
        }

        let result = try destination.moveFile(from: tempFile)
        #expect(result.lastPathComponent == "moved.bin")
        #expect(FileManager.default.fileExists(atPath: result.path))
        #expect(!FileManager.default.fileExists(atPath: tempFile.path))
    }

    @Test("test custom propagates handler error")
    func customPropagatesHandlerError() {
        let tempFile = createTempFile(content: "data", extension: "bin")
        defer { try? FileManager.default.removeItem(at: tempFile) }

        enum CustomError: Error { case intentional }

        let destination = DownloadDestination.custom { _ in
            throw CustomError.intentional
        }

        #expect(throws: CustomError.self) {
            try destination.moveFile(from: tempFile)
        }
    }

    @Test("test custom passthrough returns same URL")
    func customPassthroughReturnsSameURL() throws {
        let tempFile = createTempFile(content: "data", extension: "txt")
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let destination = DownloadDestination.custom { url in url }
        let result = try destination.moveFile(from: tempFile)

        #expect(result == tempFile)
    }
}

// MARK: - Helpers

private func createTempFile(content: String, extension ext: String) -> URL {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension(ext)
    try! content.data(using: .utf8)!.write(to: url)
    return url
}
