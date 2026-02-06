import EZNetworking
import Foundation

struct MockURLResponseValidator: ResponseValidator {
    var throwError: NetworkingError?

    func validateStatus(from urlResponse: URLResponse?) throws {
        if let throwError {
            throw throwError
        }
    }

    func validateUrl(_ url: URL?) throws -> URL {
        if let throwError {
            throw throwError
        }
        guard let url else {
            throw NetworkingError.internalError(.noURL)
        }
        return url
    }
}
