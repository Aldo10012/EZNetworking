@testable import EZNetworking
import Foundation
import Testing

@Suite("Test SendableError")
struct SendableErrorTests {

    @Test("Test Verify it returns self if already a SendableErrorWrapper")
    func asSendableError_WhenAlreadyWrapper_ReturnsSameWrapper() {
        let originalNSError = NSError(domain: "test", code: 1, userInfo: nil)
        let firstWrapper = SendableErrorWrapper(originalNSError)

        let result = firstWrapper.asSendableError

        #expect(result is SendableErrorWrapper)
        if let secondWrapper = result as? SendableErrorWrapper {
            #expect(secondWrapper.domain == firstWrapper.domain)
            #expect(secondWrapper.code == firstWrapper.code)
        }
    }

    @Test("Test when an error is ALREADY Sendable (Swift Enum)")
    func asSendableError_WhenAlreadySendable_ReturnsSelf() {
        enum MockError: Error, Sendable, Equatable { case testCase }
        let originalError = MockError.testCase

        let result = originalError.asSendableError

        #expect(result is MockError)
        #expect(result as? MockError == .testCase)
    }

    @Test("Test when an error is a legacy NSError")
    func asSendableError_WhenNSError_ReturnsWrapper() {
        let nsError = NSError(domain: "test", code: 404)
        #expect(nsError.asSendableError is SendableErrorWrapper)
    }

    @Test("test Verify wrapper handles custom non-standard error classes")
    func wrapper_WithCustomClassError() {
        // Custom classes that inherit from NSError but aren't NSError.self
        class LegacyCustomError: NSError, @unchecked Sendable { }

        let error = LegacyCustomError(domain: "legacy", code: 1, userInfo: nil)
        let result = error.asSendableError

        #expect(result is SendableErrorWrapper)
    }

    @Test("test Verify SendableErrorWrapper CustomNSError conformance")
    func wrapper_CustomNSErrorConformance() {
        let domain = "custom.logic"
        let code = 123
        let original = NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: "Message"])

        let wrapper = SendableErrorWrapper(original)

        #expect(SendableErrorWrapper.errorDomain == "EZNetworking.SendableErrorWrapper")
        #expect(wrapper.errorCode == code)
        #expect(wrapper.errorUserInfo[NSLocalizedDescriptionKey] as? String == "Message")
        #expect(wrapper.errorUserInfo["wrappedDomain"] as? String == domain)
    }
}
