@testable import EZNetworking
import Foundation
import Testing

@Suite("Test UploadState")
final class UploadStateTests {
    @Test("test UploadState equivalence")
    func uploadStateEquivalence() {
        let data = Data()
        #expect(UploadState.idle == UploadState.idle)
        #expect(UploadState.uploading == UploadState.uploading)
        #expect(UploadState.pausing == UploadState.pausing)
        #expect(UploadState.paused(resumeData: data) == UploadState.paused(resumeData: data))
        #expect(UploadState.completed == UploadState.completed)
        #expect(UploadState.failed == UploadState.failed)
        #expect(UploadState.failedButCanResume(resumeData: data) == UploadState.failedButCanResume(resumeData: data))
        #expect(UploadState.cancelled == UploadState.cancelled)
    }

    @Test("resumeData returns correct data for resumable states", arguments: [
        UploadState.paused(resumeData: "pause-data".data(using: .utf8)!),
        UploadState.failedButCanResume(resumeData: "resume-data".data(using: .utf8)!)
    ])
    func resumableStates(state: UploadState) {
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
        UploadState.idle,
        UploadState.uploading,
        UploadState.pausing,
        UploadState.completed,
        UploadState.failed,
        UploadState.cancelled
    ])
    func nonResumableStates(state: UploadState) {
        #expect(state.resumeData == nil)
    }
}
