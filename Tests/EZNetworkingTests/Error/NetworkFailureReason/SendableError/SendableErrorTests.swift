@testable import EZNetworking
import Foundation
import Testing

@Suite("Test SendableError")
struct SendableErrorTests {

    @Test("test .asSendableError for NSError")
    func asSendableErrorOnNSError() {
        let originalError = NSError(domain: "test", code: -1, userInfo: nil)
        let result = originalError.asSendableError
        #expect(result as NSObject == originalError)
    }

    @Test("test .asSendableError for URLError")
    func asSendableErrorOnURLError() {
        let originalError = URLError(.notConnectedToInternet)
        let result = originalError.asSendableError
        #expect(result as! URLError == originalError)
    }

    @Test("test .asSendableError for DecodingError")
    func asSendableErrorOnDecodingError() {
        let originalError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "test"))
        let result = originalError.asSendableError
        #expect(result is DecodingError)
    }

    @Test("test .asSendableError for Custom Sendabel Error")
    func asSendableErrorOnCustomSendableError() {
        enum MockError: Error, Sendable, Equatable { case testCase }
        let originalError = MockError.testCase

        let result = originalError.asSendableError

        #expect(result is MockError)
        #expect(result as? MockError == .testCase)
    }

    @Test("test .asSendableError for Custom Non Sendabel Error - 1")
    func asSendableErrorOnCustomNonSendableError_1() {
        enum MockError: Error, Equatable { case testCase }
        let originalError = MockError.testCase

        let result = originalError.asSendableError

        #expect(result is MockError)
        #expect(result as? MockError == .testCase)
    }

    @Test("test .asSendableError for Custom Non Sendabel Error - 2")
    func asSendableErrorOnCustomNonSendableError_2() {
        class NonSendableBox { }
        enum MockError: Error {
            case testCase(NonSendableBox)
        }
        let originalError = MockError.testCase(NonSendableBox())
        let result = originalError.asSendableError
        #expect(result is MockError)
    }

    @Test("test .asSendableError for SendableErrorWrapper")
    func asSendableErrorOnSendableErrorWrapper() {
        let originalNSError = NSError(domain: "test", code: 1, userInfo: nil)
        let firstWrapper = SendableErrorWrapper(originalNSError)

        let result = firstWrapper.asSendableError

        #expect(result is SendableErrorWrapper)
        if let secondWrapper = result as? SendableErrorWrapper {
            #expect(secondWrapper.domain == firstWrapper.domain)
            #expect(secondWrapper.code == firstWrapper.code)
        }
    }
}
