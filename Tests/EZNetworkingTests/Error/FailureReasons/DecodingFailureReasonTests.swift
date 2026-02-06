@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DecodingFailureReason")
final class DecodingFailureReasonTests {
    @Test("test decodingError case equality")
    func decodingErrorEquality() {
        let error1 = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "test"))
        let error2 = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "test"))
        let error3 = DecodingError.keyNotFound(MockCodingKey(intValue: 0)!, .init(codingPath: [], debugDescription: "test"))

        let reason1 = DecodingFailureReason.decodingError(underlying: error1)
        let reason2 = DecodingFailureReason.decodingError(underlying: error2)
        let reason3 = DecodingFailureReason.decodingError(underlying: error3)

        #expect(reason1 == reason2)
        #expect(reason1 != reason3)
    }

    @Test("test other case equality")
    func otherEquality() {
        let error1 = NSError(domain: "Test", code: 1, userInfo: nil)
        let error2 = NSError(domain: "Test", code: 1, userInfo: nil)
        let error3 = NSError(domain: "Test", code: 2, userInfo: nil)

        let reason1 = DecodingFailureReason.other(underlying: error1)
        let reason2 = DecodingFailureReason.other(underlying: error2)
        let reason3 = DecodingFailureReason.other(underlying: error3)

        #expect(reason1 == reason2)
        #expect(reason1 != reason3)
    }

    @Test("test decodingError vs other inequality")
    func decodingErrorVsOther() {
        let decodingError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "test"))
        let otherError = NSError(domain: "Test", code: 1, userInfo: nil)

        let reason1 = DecodingFailureReason.decodingError(underlying: decodingError)
        let reason2 = DecodingFailureReason.other(underlying: otherError)

        #expect(reason1 != reason2)
    }
}

private class MockCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    required init?(stringValue: String) {
        self.stringValue = ""
        self.intValue = 0
    }

    required init?(intValue: Int) {
        self.stringValue = ""
        self.intValue = 0
    }
}
