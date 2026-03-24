@testable import EZNetworking
import Foundation
import Testing

@Suite("Test UploadFailureReason")
struct UploadFailureReasonTests {
    @Test("test urlError case equality")
    func urlErrorEquality() {
        let error1 = URLError(.badURL)
        let error2 = URLError(.badURL)
        let error3 = URLError(.notConnectedToInternet)

        let reason1 = UploadFailureReason.urlError(underlying: error1)
        let reason2 = UploadFailureReason.urlError(underlying: error2)
        let reason3 = UploadFailureReason.urlError(underlying: error3)

        #expect(reason1 == reason2)
        #expect(reason1 != reason3)
    }

    @Test("test unknownError case equality")
    func unknownErrorEquality() {
        let error1 = NSError(domain: "Test", code: 1, userInfo: nil)
        let error2 = NSError(domain: "Test", code: 1, userInfo: nil)
        let error3 = NSError(domain: "Test", code: 2, userInfo: nil)

        let reason1 = UploadFailureReason.unknownError(underlying: error1)
        let reason2 = UploadFailureReason.unknownError(underlying: error2)
        let reason3 = UploadFailureReason.unknownError(underlying: error3)

        #expect(reason1 == reason2)
        #expect(reason1 != reason3)
    }

    @Test("test failedButResumable case equality")
    func failedButResumableEquality() {
        let error1 = URLError(.networkConnectionLost)
        let error2 = URLError(.networkConnectionLost)
        let error3 = URLError(.timedOut)

        let reason1 = UploadFailureReason.failedButResumable(underlying: error1)
        let reason2 = UploadFailureReason.failedButResumable(underlying: error2)
        let reason3 = UploadFailureReason.failedButResumable(underlying: error3)

        #expect(reason1 == reason2)
        #expect(reason1 != reason3)
    }

    @Test("test cannotResume case equality")
    func cannotResumeEquality() {
        let reason1 = UploadFailureReason.cannotResume
        let reason2 = UploadFailureReason.cannotResume

        #expect(reason1 == reason2)
    }

    @Test("test alreadyUploading case equality")
    func alreadyUploadingEquality() {
        let reason1 = UploadFailureReason.alreadyUploading
        let reason2 = UploadFailureReason.alreadyUploading

        #expect(reason1 == reason2)
    }

    @Test("test alreadyFinished case equality")
    func alreadyFinishedEquality() {
        let reason1 = UploadFailureReason.alreadyFinished
        let reason2 = UploadFailureReason.alreadyFinished

        #expect(reason1 == reason2)
    }

    @Test("test uploadIncompleteButResumable case equality")
    func uploadIncompleteButResumableEquality() {
        let reason1 = UploadFailureReason.uploadIncompleteButResumable
        let reason2 = UploadFailureReason.uploadIncompleteButResumable

        #expect(reason1 == reason2)
    }

    @Test("test notUploading case equality")
    func notUploadingEquality() {
        let reason1 = UploadFailureReason.notUploading
        let reason2 = UploadFailureReason.notUploading

        #expect(reason1 == reason2)
    }

    @Test("test notPaused case equality")
    func notPausedEquality() {
        let reason1 = UploadFailureReason.notPaused
        let reason2 = UploadFailureReason.notPaused

        #expect(reason1 == reason2)
    }

    @Test("test different cases are not equal")
    func differentCasesInequality() {
        let urlError = UploadFailureReason.urlError(underlying: URLError(.badURL))
        let cannotResume = UploadFailureReason.cannotResume
        let alreadyUploading = UploadFailureReason.alreadyUploading
        let alreadyFinished = UploadFailureReason.alreadyFinished
        let uploadIncompleteButResumable = UploadFailureReason.uploadIncompleteButResumable
        let notUploading = UploadFailureReason.notUploading
        let notPaused = UploadFailureReason.notPaused
        let unknownError = UploadFailureReason.unknownError(underlying: NSError(domain: "Test", code: 1, userInfo: nil))
        let failedButResumable = UploadFailureReason.failedButResumable(underlying: URLError(.networkConnectionLost))

        #expect(urlError != cannotResume)
        #expect(urlError != alreadyUploading)
        #expect(urlError != alreadyFinished)
        #expect(urlError != uploadIncompleteButResumable)
        #expect(urlError != notUploading)
        #expect(urlError != notPaused)
        #expect(urlError != unknownError)
        #expect(urlError != failedButResumable)
        #expect(cannotResume != alreadyUploading)
        #expect(cannotResume != alreadyFinished)
        #expect(cannotResume != uploadIncompleteButResumable)
        #expect(cannotResume != notUploading)
        #expect(cannotResume != notPaused)
        #expect(cannotResume != unknownError)
        #expect(cannotResume != failedButResumable)
        #expect(alreadyUploading != alreadyFinished)
        #expect(alreadyUploading != uploadIncompleteButResumable)
        #expect(alreadyUploading != notUploading)
        #expect(alreadyUploading != notPaused)
        #expect(alreadyUploading != unknownError)
        #expect(alreadyUploading != failedButResumable)
        #expect(alreadyFinished != uploadIncompleteButResumable)
        #expect(alreadyFinished != notUploading)
        #expect(alreadyFinished != notPaused)
        #expect(alreadyFinished != unknownError)
        #expect(alreadyFinished != failedButResumable)
        #expect(uploadIncompleteButResumable != notUploading)
        #expect(uploadIncompleteButResumable != notPaused)
        #expect(uploadIncompleteButResumable != unknownError)
        #expect(uploadIncompleteButResumable != failedButResumable)
        #expect(notUploading != notPaused)
        #expect(notUploading != unknownError)
        #expect(notUploading != failedButResumable)
        #expect(notPaused != unknownError)
        #expect(notPaused != failedButResumable)
        #expect(unknownError != failedButResumable)
    }

    @Test("test urlError vs unknownError even with same NSError")
    func urlErrorVsUnknownErrorWithSameNSError() {
        let urlError = URLError(.badURL)
        let nsError = urlError as NSError

        let reason1 = UploadFailureReason.urlError(underlying: urlError)
        let reason2 = UploadFailureReason.unknownError(underlying: nsError)

        #expect(reason1 != reason2)
    }

    @Test("test failedButResumable vs unknownError with same underlying error")
    func failedButResumableVsUnknownErrorWithSameError() {
        let error = NSError(domain: "Test", code: 1, userInfo: nil)

        let reason1 = UploadFailureReason.failedButResumable(underlying: error)
        let reason2 = UploadFailureReason.unknownError(underlying: error)

        #expect(reason1 != reason2)
    }
}
