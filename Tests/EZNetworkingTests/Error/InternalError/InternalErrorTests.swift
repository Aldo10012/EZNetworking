@testable import EZNetworking
import Foundation
import Testing

@Suite("Test InternalError")
final class InternalErrorTests {
    @Test("test InternalError Is Equatable", arguments: zip(errorList, errorList))
    func couldNotParseIsEquatable(inputA: InternalError, inputB: InternalError) {
        #expect(inputA == inputB)
    }

    @Test("test Different InternalError Are Not Equatable")
    func differentInternalErrorAreNotEquatable() {
        let errA = InternalError.requestFailed(NetworkingError.httpError(.init(statusCode: 400, headers: [:])))
        let errB = InternalError.noHTTPURLResponse
        #expect(errA != errB)

    }

    private static let errorList: [InternalError] = [
        InternalError.requestFailed(NetworkingError.httpError(.init(statusCode: 400, headers: [:]))),
        InternalError.noHTTPURLResponse
    ]
}
