@testable import EZNetworking
import Foundation
import Testing

@Suite("Test URLBuildFailureReason")
final class URLBuildFailureReasonTests {
    @Test("test URLBuildFailureReason is equatable", arguments: zip(list, list))
    func urlBuildFailureReasoneIsEquatable(inputA: URLBuildFailureReason, inputB: URLBuildFailureReason) {
        #expect(inputA == inputB)
    }

    @Test("test URLBuildFailureReason is not equatable with different cases", arguments: zip(list, list.reversed()))
    func urlBuildFailureReasoneIsEquatableWithDifferentCases(inputA: URLBuildFailureReason, inputB: URLBuildFailureReason) {
        #expect(inputA != inputB)
    }

    @Test("test invalidScheme equatability with different inputs")
    func invalidSchemeEquatabilityWithDifferentInputs() {
        #expect(URLBuildFailureReason.invalidScheme(nil) == URLBuildFailureReason.invalidScheme(nil))
        #expect(URLBuildFailureReason.invalidScheme("") == URLBuildFailureReason.invalidScheme(""))
        #expect(URLBuildFailureReason.invalidScheme("test") == URLBuildFailureReason.invalidScheme("test"))

        #expect(URLBuildFailureReason.invalidScheme(nil) != URLBuildFailureReason.invalidScheme(""))
        #expect(URLBuildFailureReason.invalidScheme(nil) != URLBuildFailureReason.invalidScheme("test"))
        #expect(URLBuildFailureReason.invalidScheme("") != URLBuildFailureReason.invalidScheme("test"))
    }

    private static let list: [URLBuildFailureReason] = [
        .noURL,
        .invalidURL,
        .missingHost,
        .invalidScheme("test")
    ]
}
