@testable import EZNetworking
import Foundation
import Testing

@Suite("Test InternalError")
final class InternalErrorTests {
    @Test("test InternalError Is Equatable", arguments: zip(errorList, errorList))
    func couldNotParseIsEquatable(inputA: InternalError, inputB: InternalError) {
        #expect(inputA == inputB)
    }

    private static let errorList: [InternalError] = [
        InternalError.requestFailed(NSError(domain: "", code: 0, userInfo: nil))
    ]
}
