@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DownloadFailureReason")
struct DownloadFailureReasonTests {
    @Test("test urlError case equality")
    func urlErrorEquality() {
        let error1 = URLError(.badURL)
        let error2 = URLError(.badURL)
        let error3 = URLError(.notConnectedToInternet)

        let reason1 = DownloadFailureReason.urlError(underlying: error1)
        let reason2 = DownloadFailureReason.urlError(underlying: error2)
        let reason3 = DownloadFailureReason.urlError(underlying: error3)

        #expect(reason1 == reason2)
        #expect(reason1 != reason3)
    }

    @Test("test unknownError case equality")
    func unknownErrorEquality() {
        let error1 = NSError(domain: "Test", code: 1, userInfo: nil)
        let error2 = NSError(domain: "Test", code: 1, userInfo: nil)
        let error3 = NSError(domain: "Test", code: 2, userInfo: nil)

        let reason1 = DownloadFailureReason.unknownError(underlying: error1)
        let reason2 = DownloadFailureReason.unknownError(underlying: error2)
        let reason3 = DownloadFailureReason.unknownError(underlying: error3)

        #expect(reason1 == reason2)
        #expect(reason1 != reason3)
    }

    @Test("test failedButResumable case equality")
    func failedButResumableEquality() {
        let error1 = URLError(.networkConnectionLost)
        let error2 = URLError(.networkConnectionLost)
        let error3 = URLError(.timedOut)

        let reason1 = DownloadFailureReason.failedButResumable(underlying: error1)
        let reason2 = DownloadFailureReason.failedButResumable(underlying: error2)
        let reason3 = DownloadFailureReason.failedButResumable(underlying: error3)

        #expect(reason1 == reason2)
        #expect(reason1 != reason3)
    }

    @Test("test cannotResume case equality")
    func cannotResumeEquality() {
        let reason1 = DownloadFailureReason.cannotResume
        let reason2 = DownloadFailureReason.cannotResume

        #expect(reason1 == reason2)
    }

    @Test("test alreadyDownloading case equality")
    func alreadyDownloadingEquality() {
        let reason1 = DownloadFailureReason.alreadyDownloading
        let reason2 = DownloadFailureReason.alreadyDownloading

        #expect(reason1 == reason2)
    }

    @Test("test alreadyFinished case equality")
    func alreadyFinishedEquality() {
        let reason1 = DownloadFailureReason.alreadyFinished
        let reason2 = DownloadFailureReason.alreadyFinished

        #expect(reason1 == reason2)
    }

    @Test("test downloadIncompleteButResumable case equality")
    func downloadIncompleteButResumableEquality() {
        let reason1 = DownloadFailureReason.downloadIncompleteButResumable
        let reason2 = DownloadFailureReason.downloadIncompleteButResumable

        #expect(reason1 == reason2)
    }

    @Test("test notDownloading case equality")
    func notDownloadingEquality() {
        let reason1 = DownloadFailureReason.notDownloading
        let reason2 = DownloadFailureReason.notDownloading

        #expect(reason1 == reason2)
    }

    @Test("test notPaused case equality")
    func notPausedEquality() {
        let reason1 = DownloadFailureReason.notPaused
        let reason2 = DownloadFailureReason.notPaused

        #expect(reason1 == reason2)
    }

    @Test("test fileMoveFailed case equality")
    func fileMoveFailedEquality() {
        let error1 = NSError(domain: "Test", code: 1, userInfo: nil)
        let error2 = NSError(domain: "Test", code: 1, userInfo: nil)
        let error3 = NSError(domain: "Test", code: 2, userInfo: nil)

        let reason1 = DownloadFailureReason.fileMoveFailed(underlying: error1)
        let reason2 = DownloadFailureReason.fileMoveFailed(underlying: error2)
        let reason3 = DownloadFailureReason.fileMoveFailed(underlying: error3)

        #expect(reason1 == reason2)
        #expect(reason1 != reason3)
    }

    @Test("test different cases are not equal")
    func differentCasesInequality() {
        let allCases = allDistinctCases
        for i in 0..<allCases.count {
            for j in (i + 1)..<allCases.count {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test("test urlError vs unknownError even with same NSError")
    func urlErrorVsUnknownErrorWithSameNSError() {
        let urlError = URLError(.badURL)
        let nsError = urlError as NSError

        let reason1 = DownloadFailureReason.urlError(underlying: urlError)
        let reason2 = DownloadFailureReason.unknownError(underlying: nsError)

        #expect(reason1 != reason2)
    }

    @Test("test failedButResumable vs unknownError with same underlying error")
    func failedButResumableVsUnknownErrorWithSameError() {
        let error = NSError(domain: "Test", code: 1, userInfo: nil)

        let reason1 = DownloadFailureReason.failedButResumable(underlying: error)
        let reason2 = DownloadFailureReason.unknownError(underlying: error)

        #expect(reason1 != reason2)
    }

    @Test("test fileMoveFailed vs unknownError with same underlying error")
    func fileMoveFailedVsUnknownErrorWithSameError() {
        let error = NSError(domain: "Test", code: 1, userInfo: nil)

        let reason1 = DownloadFailureReason.fileMoveFailed(underlying: error)
        let reason2 = DownloadFailureReason.unknownError(underlying: error)

        #expect(reason1 != reason2)
    }
}

// MARK: - Helpers

private let allDistinctCases: [DownloadFailureReason] = [
    .urlError(underlying: URLError(.badURL)),
    .cannotResume,
    .alreadyDownloading,
    .alreadyFinished,
    .downloadIncompleteButResumable,
    .notDownloading,
    .notPaused,
    .unknownError(underlying: NSError(domain: "Test", code: 1, userInfo: nil)),
    .failedButResumable(underlying: URLError(.networkConnectionLost)),
    .fileMoveFailed(underlying: NSError(domain: "Test", code: 3, userInfo: nil))
]
