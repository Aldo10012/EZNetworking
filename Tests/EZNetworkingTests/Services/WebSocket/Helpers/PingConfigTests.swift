@testable import EZNetworking
import Foundation
import Testing

@Suite("Test PingConfig")
final class PingConfigTests {
    @Test("test default ping configurations")
    func defaultPingConfigurations() {
        let sut = PingConfig()
        #expect(sut.maxPingFailures == 3)
        #expect(sut.pingInterval == .seconds(30))
    }

    @Test("test setting PingConfig(maxPingFailures: 0) sets maxPingFailures to 1")
    func settingMaxPingFailuresToZeroGetsSetToOne() {
        let sut = PingConfig(maxPingFailures: 0)
        #expect(sut.maxPingFailures == 1)
    }

    @Test("test .waitForPingInterval() sleeps for the configured pingInterval")
    func testWaitForPingInterval() async {
        let clock = MockClock()
        let sut = PingConfig(pingInterval: .seconds(3), clock: clock)
        await sut.waitForPingInterval()
        #expect(clock.sleptDurations == [.seconds(3)])
    }
}
