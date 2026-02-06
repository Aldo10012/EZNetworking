@testable import EZNetworking
import Foundation
import Testing

@Suite("Test InternalError")
final class InternalErrorTests {
    @Test("test InternalError Is Equatable", arguments: zip(InternalErrorList, InternalErrorList))
    func couldNotParseIsEquatable(inputA: InternalError, inputB: InternalError) {
        #expect(inputA == inputB)
    }

    @Test("test Different InternalError Are Not Equatable")
    func differentInternalErrorAreNotEquatable() {
        #expect(InternalError.noHTTPURLResponse != InternalError.requestFailed(NetworkingError.httpError(.init(statusCode: 400, headers: [:]))))
    }

    private static let InternalErrorList: [InternalError] = [
        InternalError.requestFailed(NetworkingError.httpError(.init(statusCode: 400, headers: [:]))),
        InternalError.noHTTPURLResponse
    ]
}
