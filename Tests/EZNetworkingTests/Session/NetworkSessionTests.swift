@testable import EZNetworking
import Foundation
import Testing

@Suite("Test NetworkSession")
final class NetworkSessionTests {

    @Test("test Session default configuration")
    func sessionDefaultConfiguration() throws {
        #expect(Session().configuration == URLSessionConfiguration.default)
    }

    @Test("test Session default delegateQueue")
    func sessionDefaultDelegateQueue() throws {
        #expect(Session().delegateQueue == nil)
    }

    @Test("test Session default delegate default interceptors")
    func sessionDefaultDelegate() throws {
        let defaultDelegate = Session().delegate
        #expect(defaultDelegate.authenticationInterceptor == nil)
        #expect(defaultDelegate.cacheInterceptor == nil)
        #expect(defaultDelegate.redirectInterceptor == nil)
        #expect(defaultDelegate.metricsInterceptor == nil)
    }
}
