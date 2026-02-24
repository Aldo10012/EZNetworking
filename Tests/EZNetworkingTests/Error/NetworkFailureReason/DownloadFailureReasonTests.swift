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

    @Test("test invalidResponse case equality")
    func invalidResponseEquality() {
        let reason1 = DownloadFailureReason.invalidResponse
        let reason2 = DownloadFailureReason.invalidResponse

        #expect(reason1 == reason2)
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

    @Test("test different cases are not equal")
    func differentCasesInequality() {
        let urlError = DownloadFailureReason.urlError(underlying: URLError(.badURL))
        let invalidResponse = DownloadFailureReason.invalidResponse
        let cannotResume = DownloadFailureReason.cannotResume
        let alreadyDownloading = DownloadFailureReason.alreadyDownloading
        let notDownloading = DownloadFailureReason.notDownloading
        let notPaused = DownloadFailureReason.notPaused
        let unknownError = DownloadFailureReason.unknownError(underlying: NSError(domain: "Test", code: 1, userInfo: nil))

        #expect(urlError != invalidResponse)
        #expect(urlError != cannotResume)
        #expect(urlError != alreadyDownloading)
        #expect(urlError != notDownloading)
        #expect(urlError != notPaused)
        #expect(urlError != unknownError)
        #expect(invalidResponse != cannotResume)
        #expect(invalidResponse != alreadyDownloading)
        #expect(invalidResponse != notDownloading)
        #expect(invalidResponse != notPaused)
        #expect(invalidResponse != unknownError)
        #expect(cannotResume != alreadyDownloading)
        #expect(cannotResume != notDownloading)
        #expect(cannotResume != notPaused)
        #expect(cannotResume != unknownError)
        #expect(alreadyDownloading != notDownloading)
        #expect(alreadyDownloading != notPaused)
        #expect(alreadyDownloading != unknownError)
        #expect(notDownloading != notPaused)
        #expect(notDownloading != unknownError)
        #expect(notPaused != unknownError)
    }

    @Test("test urlError vs unknownError even with same NSError")
    func urlErrorVsUnknownErrorWithSameNSError() {
        let urlError = URLError(.badURL)
        let nsError = urlError as NSError

        let reason1 = DownloadFailureReason.urlError(underlying: urlError)
        let reason2 = DownloadFailureReason.unknownError(underlying: nsError)

        #expect(reason1 != reason2)
    }
}
