@testable import EZNetworking
import Foundation
import Testing

@Suite("Test EZURLSessionDataTask")
final class EZURLSessionDataTaskTests {
    @Test("test initializing EZURLSessionDataTask does not trigger async work block")
    func initializingEZURLSessionDataTaskDoesNotTriggerAsyncWorkBlcok() async {
        var didTriggerBlock = false
        _ = EZURLSessionDataTask(work: {
            didTriggerBlock = true
        })
        try? await Task.sleep(nanoseconds: 1_000)
        #expect(didTriggerBlock == false)
    }

    @Test("test initializing EZURLSessionDataTask does trigger async work block")
    func initializingEZURLSessionDataTaskDoesTriggerAsyncWorkBlcok() async {
        var didTriggerBlock = false
        let sut = EZURLSessionDataTask(work: {
            didTriggerBlock = true
        })
        sut.resume()
        try? await Task.sleep(nanoseconds: 1_000)
        #expect(didTriggerBlock == true)
    }

    @Test("test cancel cancels the async work block")
    func cancelCancelsAsyncWorkBlock() async {
        var didFinish = false
        let sut = EZURLSessionDataTask(work: {
            do {
                try await Task.sleep(nanoseconds: 200_000_000)
                if !Task.isCancelled {
                    didFinish = true
                }
            } catch {
                // Task was cancelled
            }
        })
        sut.resume()
        sut.cancel()
        try? await Task.sleep(nanoseconds: 300_000_000)
        #expect(didFinish == false)
    }

    @Test("test calling resume twice only triggers work once")
    func resumeIsIdempotent() async {
        var runCount = 0
        let sut = EZURLSessionDataTask(work: {
            runCount += 1
        })
        sut.resume()
        sut.resume()
        try? await Task.sleep(nanoseconds: 100_000_000)
        #expect(runCount == 1)
    }

    @Test("test resume, cancel, then resume again does not trigger work twice")
    func resumeCancelResumeDoesNotTriggerWorkTwice() async {
        var runCount = 0
        let sut = EZURLSessionDataTask(work: {
            runCount += 1
        })
        sut.resume()
        try? await Task.sleep(nanoseconds: 1_000)
        sut.cancel()
        try? await Task.sleep(nanoseconds: 1_000)
        sut.resume()
        try? await Task.sleep(nanoseconds: 1_000)
        #expect(runCount == 1)
    }
}
