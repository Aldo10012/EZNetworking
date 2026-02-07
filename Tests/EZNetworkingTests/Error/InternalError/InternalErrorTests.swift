@testable import EZNetworking
import Foundation
import Testing

@Suite("Test InternalError")
final class InternalErrorTests {
    @Test("test InternalError Is Equatable")
    func couldNotParseIsEquatable() {
        enum DummyError: Error {
            case errorA, errorB
        }
        let errorA = InternalError.requestFailed(DummyError.errorA)
        let errorB = InternalError.requestFailed(DummyError.errorA)
        let errorC = InternalError.requestFailed(DummyError.errorB)
        #expect(errorA == errorB)
        #expect(errorA != errorC)
    }
}
