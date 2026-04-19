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
}
