@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DownloadEvent")
final class DownloadEventTests {
    @Test("test DownloadEvent equality", arguments: zip(list, list))
    func equality(inputA: DownloadEvent, inputB: DownloadEvent) {
        #expect(inputA == inputB)
    }

    @Test("test DownloadEvent non equality", arguments: zip(list, list.reversed()))
    func nonEquality(inputA: DownloadEvent, inputB: DownloadEvent) {
        #expect(inputA != inputB)
    }

    @Test("test same case with different inputs are not equatable")
    func sameCaseWithDifferentINputsAreNotEquatable() {
        let event1 = DownloadEvent.progress(0.1)
        let event2 = DownloadEvent.progress(0.8)
        let event3 = DownloadEvent.completed(DownloadEventTests.urlA)
        let event4 = DownloadEvent.completed(DownloadEventTests.urlB)
        let event5 = DownloadEvent.failed(.couldNotBuildURLRequest(reason: .noURL))
        let event6 = DownloadEvent.failed(.responseValidationFailed(reason: .noURLResponse))

        #expect(event1 != event2)
        #expect(event3 != event4)
        #expect(event5 != event6)
    }

    private static let list: [DownloadEvent] = [
        .started,
        .paused,
        .resumed,
        .cancelled,
        .progress(0.2),
        .progress(0.6),
        .completed(urlA),
        .failed(.couldNotBuildURLRequest(reason: .invalidURL))
    ]

    private static let urlA = URL(string: "https://www.example.com")!
    private static let urlB = URL(string: "https://www.google.com")!
}
