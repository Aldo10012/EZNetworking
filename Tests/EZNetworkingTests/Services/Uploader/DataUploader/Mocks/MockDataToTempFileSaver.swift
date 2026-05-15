@testable import EZNetworking
import Foundation

final class MockDataToTempFileSaver: DataToTempFileSaver, @unchecked Sendable {
    private let lock = NSLock()
    private var _saveCount = 0
    private var _clearCount = 0
    private var _saveError: Error?
    private var _clearError: Error?
    private var _savedURL = URL(fileURLWithPath: "/tmp/mock-saved-file")
    private var _clearedURLs: [URL] = []
    private var _savedData: [Data] = []

    var saveCount: Int { lock.withLock { _saveCount } }
    var clearCount: Int { lock.withLock { _clearCount } }
    var clearedURLs: [URL] { lock.withLock { _clearedURLs } }
    var savedData: [Data] { lock.withLock { _savedData } }

    func setSaveError(_ error: Error?) {
        lock.withLock { _saveError = error }
    }

    func setClearError(_ error: Error?) {
        lock.withLock { _clearError = error }
    }

    func setSavedURL(_ url: URL) {
        lock.withLock { _savedURL = url }
    }

    func saveToTempFile(_ data: Data) throws -> URL {
        try lock.withLock {
            _saveCount += 1
            _savedData.append(data)
            if let error = _saveError { throw error }
            return _savedURL
        }
    }

    func clearTempFile(at url: URL) throws {
        try lock.withLock {
            _clearCount += 1
            _clearedURLs.append(url)
            if let error = _clearError { throw error }
        }
    }
}
