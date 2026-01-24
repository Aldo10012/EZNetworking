@testable import EZNetworking
import Foundation
import Testing

@Suite("Test Session")
final class SessionTests {

    @Test("test Session default configuration")
    func sessionDefaultConfiguration() {
        #expect(Session().configuration == URLSessionConfiguration.default)
    }

    @Test("test Session default delegateQueue")
    func sessionDefaultDelegateQueue() {
        #expect(Session().delegateQueue == nil)
    }

    @Test("test Session default delegate default interceptors")
    func sessionDefaultDelegate() {
        let defaultDelegate = Session().delegate
        #expect(defaultDelegate.authenticationInterceptor == nil)
        #expect(defaultDelegate.cacheInterceptor == nil)
        #expect(defaultDelegate.redirectInterceptor == nil)
        #expect(defaultDelegate.metricsInterceptor == nil)
    }

    @Test("test Session urlSession configuration")
    func sessionUrlSessionDefaultConfiguration() throws {
        let urlSession = try #require(Session().urlSession as? URLSession)
        #expect(urlSession.configuration == URLSessionConfiguration.default)
    }

    @Test("test Session urlSession delegate")
    func sessionUrlSessionDefaultDelegate() throws {
        let urlSession = try #require(Session().urlSession as? URLSession)
        let delegate = try #require(urlSession.delegate as? SessionDelegate)
        #expect(delegate.authenticationInterceptor == nil)
        #expect(delegate.cacheInterceptor == nil)
        #expect(delegate.redirectInterceptor == nil)
        #expect(delegate.metricsInterceptor == nil)
    }
}
