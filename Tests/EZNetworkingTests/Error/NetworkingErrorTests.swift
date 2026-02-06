@testable import EZNetworking
import Foundation
import Testing

@Suite("Test NetworkingError")
final class NetworkingErrorTests {
    // MARK: .couldNotBuildURLRequest(reason:_)

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

    // MARK: .decodingFailed(reason:_)

    @Test("test NetworkingError.decodingFailed(_) equatability")
    func networkingErrorDecodingFailedEquatability() {
        let decodingError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "test"))
        let err1 = NetworkingError.decodingFailed(reason: .decodingError(underlying: decodingError))
        let err2 = NetworkingError.decodingFailed(reason: .decodingError(underlying: decodingError))
        #expect(err1 == err2)
    }

    @Test("test NetworkingError.decodingFailed(_) non equatability")
    func networkingErrorDecodingFailedNonEquatability() {
        let decodingError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "test"))
        let otherError = NSError(domain: "Test", code: 1, userInfo: nil)
        let err1 = NetworkingError.decodingFailed(reason: .decodingError(underlying: decodingError))
        let err2 = NetworkingError.decodingFailed(reason: .other(underlying: otherError))
        #expect(err1 != err2)
    }
}
