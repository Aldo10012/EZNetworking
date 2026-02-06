@testable import EZNetworking
import Foundation
import Testing

@Suite("Test NetworkingError")
final class NetworkingErrorTests {
    @Test("test NetworkingError.couldNotBuildURLRequest(_) equatability")
    func networkingErrorCouldNotBuildURLRequestEquatability() {
        let err1 = NetworkingError.couldNotBuildURLRequest(reason: .noURL)
        let err2 = NetworkingError.couldNotBuildURLRequest(reason: .noURL)
        #expect(err1 == err2)
    }

    @Test("test NetworkingError.couldNotBuildURLRequest(_) non equatability")
    func networkingErrorCouldNotBuildURLRequestNonEquatability() {
        let err1 = NetworkingError.couldNotBuildURLRequest(reason: .noURL)
        let err2 = NetworkingError.couldNotBuildURLRequest(reason: .invalidURL)
        #expect(err1 != err2)
    }
}
