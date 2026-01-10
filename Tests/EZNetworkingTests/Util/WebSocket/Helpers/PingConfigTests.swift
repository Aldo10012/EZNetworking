@testable import EZNetworking
import Foundation
import Testing

@Suite("Test PingConfig")
final class PingConfigTests {
    
    @Test("test default ping configurations")
    func testDefaultPingConfigurations() {
        let sut = PingConfig()
        #expect(sut.maxPingFailures == 3)
        #expect(sut.pingInterval == .seconds(30))
    }
    
    @Test("test setting PingConfig(maxPingFailures: 0) sets maxPingFailures to 1")
    func testSettingMaxPingFailuresToZeroGetsSetToOne() {
        let sut = PingConfig(maxPingFailures: 0)
        #expect(sut.maxPingFailures == 1)
    }
    
    @Test("test .waitForPingInterval()")
    func testWaitForPingInterval() async {
        let sut = PingConfig(pingInterval: .nanoseconds(1))
        await sut.waitForPingInterval()
        #expect(true, "waitForPingInterval did return")
    }
    
}

@Suite("Test IntervalDuration")
final class IntervalDurationTests {
    
    @Test("test IntervalDuration equality")
    func testIntervalDurationEquality() {
        let oneSecond = IntervalDuration.seconds(1)
        let tenSecond = IntervalDuration.seconds(10)
        let oneMilliseconds = IntervalDuration.milliseconds(1)
        let tenMilliseconds = IntervalDuration.milliseconds(10)
        let oneNanoseconds = IntervalDuration.nanoseconds(1)
        let tenNanoseconds = IntervalDuration.nanoseconds(10)
        
        #expect(oneSecond == oneSecond)
        #expect(oneSecond != tenSecond)
        
        #expect(oneMilliseconds == oneMilliseconds)
        #expect(oneMilliseconds != tenMilliseconds)
        
        #expect(oneNanoseconds == oneNanoseconds)
        #expect(oneNanoseconds != tenNanoseconds)
        
        #expect(oneSecond != oneMilliseconds)
        #expect(oneMilliseconds != oneNanoseconds)
        #expect(oneNanoseconds != oneSecond)
    }
}
