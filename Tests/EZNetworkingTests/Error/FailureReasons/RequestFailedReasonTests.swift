@testable import EZNetworking
import Foundation
import Testing

@Suite("Test RequestFailedReason")
struct RequestFailedReasonTests {
    @Test("test urlError case equality")
    func urlErrorEquality() {
        let error1 = URLError(.badURL)
        let error2 = URLError(.badURL)
        let error3 = URLError(.notConnectedToInternet)

        let reason1 = RequestFailedReason.urlError(underlying: error1)
        let reason2 = RequestFailedReason.urlError(underlying: error2)
        let reason3 = RequestFailedReason.urlError(underlying: error3)

        #expect(reason1 == reason2)
        #expect(reason1 != reason3)
    }

    @Test("test unknownError case equality")
    func unknownErrorEquality() {
        let error1 = NSError(domain: "Test", code: 1, userInfo: nil)
        let error2 = NSError(domain: "Test", code: 1, userInfo: nil)
        let error3 = NSError(domain: "Test", code: 2, userInfo: nil)

        let reason1 = RequestFailedReason.unknownError(underlying: error1)
        let reason2 = RequestFailedReason.unknownError(underlying: error2)
        let reason3 = RequestFailedReason.unknownError(underlying: error3)

        #expect(reason1 == reason2)
        #expect(reason1 != reason3)
    }

    @Test("test urlError vs unknownError inequality")
    func urlErrorVsUnknownError() {
        let urlError = URLError(.badURL)
        let otherError = NSError(domain: "Test", code: 1, userInfo: nil)

        let reason1 = RequestFailedReason.urlError(underlying: urlError)
        let reason2 = RequestFailedReason.unknownError(underlying: otherError)

        #expect(reason1 != reason2)
    }

    @Test("test urlError vs unknownError even with same NSError")
    func urlErrorVsUnknownErrorWithSameNSError() {
        let urlError = URLError(.badURL)
        let nsError = urlError as NSError

        let reason1 = RequestFailedReason.urlError(underlying: urlError)
        let reason2 = RequestFailedReason.unknownError(underlying: nsError)

        #expect(reason1 != reason2)
    }

    @Test("test urlError with normal underlying URLError")
    func urlErrorNormal() {
        let error1 = URLError(.badURL)
        let error2 = URLError(.badURL)

        let reason1 = RequestFailedReason.urlError(underlying: error1)
        let reason2 = RequestFailedReason.urlError(underlying: error2)

        #expect(reason1 == reason2)
    }

    @Test("test unknownError with normal underlying Error")
    func unknownErrorNormal() {
        let error1 = NSError(domain: "Test", code: 1, userInfo: nil)
        let error2 = NSError(domain: "Test", code: 1, userInfo: nil)

        let reason1 = RequestFailedReason.unknownError(underlying: error1)
        let reason2 = RequestFailedReason.unknownError(underlying: error2)

        #expect(reason1 == reason2)
    }
}
