@testable import EZNetworking
import Foundation
import Testing

@Suite("Test UploadEvent")
final class UploadEventTests {
    @Test("test UploadEvent equality", arguments: zip(list, list))
    func equality(inputA: UploadEvent, inputB: UploadEvent) {
        #expect(inputA == inputB)
    }

    @Test("test UploadEvent non equality", arguments: zip(list, list.reversed()))
    func nonEquality(inputA: UploadEvent, inputB: UploadEvent) {
        #expect(inputA != inputB)
    }

    @Test("test same case with different inputs are not equatable")
    func sameCaseWithDifferentInputsAreNotEquatable() {
        let event1 = UploadEvent.progress(0.1)
        let event2 = UploadEvent.progress(0.8)
        let event3 = UploadEvent.completed(UploadEventTests.dataA)
        let event4 = UploadEvent.completed(UploadEventTests.dataB)
        let event5 = UploadEvent.failed(.couldNotBuildURLRequest(reason: .noURL))
        let event6 = UploadEvent.failed(.responseValidationFailed(reason: .noURLResponse))

        #expect(event1 != event2)
        #expect(event3 != event4)
        #expect(event5 != event6)
    }

    private static let list: [UploadEvent] = [
        .progress(0.2),
        .progress(0.6),
        .completed(dataA),
        .completed(dataB),
        .failed(.couldNotBuildURLRequest(reason: .invalidURL)),
        .failed(.uploadFailed(reason: .failedButResumable(underlying: URLError(.networkConnectionLost))))
    ]

    private static let dataA = Data("response body A".utf8)
    private static let dataB = Data("response body B".utf8)
}
