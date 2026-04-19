@testable import EZNetworking
import Foundation
import Testing

@Suite("Test DownloadState")
final class DownloadStateTests {
    @Test("test DownloadState equivalence")
    func testDownloadStateEquivalence() {
        let data = Data()
        #expect(DownloadState.idle == DownloadState.idle)
        #expect(DownloadState.downloading == DownloadState.downloading)
        #expect(DownloadState.pausing == DownloadState.pausing)
        #expect(DownloadState.paused(resumeData: data) == DownloadState.paused(resumeData: data))
        #expect(DownloadState.completed == DownloadState.completed)
        #expect(DownloadState.failed == DownloadState.failed)
        #expect(DownloadState.failedButCanResume(resumeData: data) == DownloadState.failedButCanResume(resumeData: data))
        #expect(DownloadState.cancelled == DownloadState.cancelled)
    }

    @Test("resumeData returns correct data for resumable states", arguments: [
        DownloadState.paused(resumeData: "pause-data".data(using: .utf8)!),
        DownloadState.failedButCanResume(resumeData: "resume-data".data(using: .utf8)!)
    ])
    func testResumableStates(state: DownloadState) {
        // Assert that data is not nil and matches expected input
        #expect(state.resumeData != nil)

        if case let .paused(data) = state {
            #expect(state.resumeData == data)
        } else if case let .failedButCanResume(data) = state {
            #expect(state.resumeData == data)
        } else {
            Issue.record("Expected success")
        }
    }

    @Test("resumeData returns nil for non-resumable states", arguments: [
        DownloadState.idle,
        DownloadState.downloading,
        DownloadState.pausing,
        DownloadState.completed,
        DownloadState.failed,
        DownloadState.cancelled
    ])
    func testNonResumableStates(state: DownloadState) {
        #expect(state.resumeData == nil)
    }
}
