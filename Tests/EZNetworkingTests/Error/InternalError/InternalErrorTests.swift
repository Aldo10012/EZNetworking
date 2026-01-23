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
        #expect(InternalError.unknown != InternalError.noData)
    }

    private static let InternalErrorList: [InternalError] = [
        InternalError.noURL,
        InternalError.invalidURL,
        InternalError.missingHost,
        InternalError.invalidScheme(""),
        InternalError.couldNotParse(underlying: NSError(domain: "test", code: -1)),
        InternalError.invalidError,
        InternalError.noData,
        InternalError.noResponse,
        InternalError.requestFailed(NetworkingError.httpError(.init(statusCode: 400, headers: [:]))),
        InternalError.noRequest,
        InternalError.noHTTPURLResponse,
        InternalError.invalidImageData,
        InternalError.lostReferenceOfSelf,
        InternalError.unknown
    ]
}
