@testable import EZNetworking
import Foundation
import Testing

@Suite("Test PingConfig")
final class PingConfigTests {
    
    @Test("test PingConfig default values")
    func testPingConfigDefaultValues() {
        let sut = PingConfig()
        #expect(sut.pingInterval == 30)
        #expect(sut.maxPingFailures == 3)
    }
    
    @Test("test PingConfig custom values")
    func testPingConfigCustomValues() {
        let sut = PingConfig(pingInterval: 10, maxPingFailures: 5)
        #expect(sut.pingInterval == 10)
        #expect(sut.maxPingFailures == 5)
    }
}
