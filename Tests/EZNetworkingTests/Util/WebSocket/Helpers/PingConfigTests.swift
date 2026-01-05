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
