@testable import EZNetworking
import Foundation
import Testing

@Suite("Test ResponseValidationFailureReason")
final class ResponseValidationFailureReasonTests {

    @Test("test ResponseValidationFailureReason is equatable", arguments: zip(list, list))
    func urlResponseValidationFailureReasoneIsEquatable(inputA: ResponseValidationFailureReason, inputB: ResponseValidationFailureReason) {
        #expect(inputA == inputB)
    }

    @Test("test ResponseValidationFailureReason is not equatable to different cases")
    func urlResponseValidationFailureReasoneIsNotEquatableToDifferentCases() {
        let reason1 = ResponseValidationFailureReason.noHTTPURLResponse
        let reason2 = ResponseValidationFailureReason.badHTTPResponse(underlying: HTTPError(statusCode: 400))
        #expect(reason1 != reason2)
    }

    @Test("test ResponseValidationFailureReason badHTTPResponse not equatable if different")
    func urlResponseValidationFailureReasoneBadHTTPResponseIsNotEquatableIfDifferent() {
        let reason1 = ResponseValidationFailureReason.badHTTPResponse(underlying: HTTPError(statusCode: 500))
        let reason2 = ResponseValidationFailureReason.badHTTPResponse(underlying: HTTPError(statusCode: 400))
        #expect(reason1 != reason2)
    }

    private static let list: [ResponseValidationFailureReason] = [
        .noHTTPURLResponse,
        .badHTTPResponse(underlying: HTTPError(statusCode: 400))
    ]
}
