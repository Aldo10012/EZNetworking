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

    // MARK: .responseValidationFailed(reason:_)

    @Test("test NetworkingError.responseValidationFailed(_) equatability")
    func networkingErrorResponseValidationFailedEquatability() {
        let err1 = NetworkingError.responseValidationFailed(reason: .noHTTPURLResponse)
        let err2 = NetworkingError.responseValidationFailed(reason: .noHTTPURLResponse)
        #expect(err1 == err2)
    }

    @Test("test NetworkingError.responseValidationFailed(_) non equatability")
    func networkingErrorResponseValidationFailedNonEquatability() {
        let err1 = NetworkingError.responseValidationFailed(reason: .noHTTPURLResponse)
        let err2 = NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: .init(statusCode: 400)))
        #expect(err1 != err2)
    }

    // MARK: .requestFailed(reason:_)

    @Test("test NetworkingError.requestFailed(_) equatability")
    func networkingErrorRequestFailedEquatability() {
        let err1 = NetworkingError.requestFailed(reason: .urlError(underlying: URLError(.badURL)))
        let err2 = NetworkingError.requestFailed(reason: .urlError(underlying: URLError(.badURL)))
        #expect(err1 == err2)
    }

    @Test("test NetworkingError.responseValidationFailed(_) non equatability")
    func networkingErrorRequestFailedNonEquatability() {
        enum DummyError: Error {
            case error
        }
        let err1 = NetworkingError.requestFailed(reason: .urlError(underlying: URLError(.badURL)))
        let err2 = NetworkingError.requestFailed(reason: .unknownError(underlying: DummyError.error))
        #expect(err1 != err2)
    }
}
