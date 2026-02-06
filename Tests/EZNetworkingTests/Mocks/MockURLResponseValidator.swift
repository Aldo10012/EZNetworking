import EZNetworking
import Foundation

struct MockURLResponseValidator: ResponseValidator {
    var throwError: Error?

    func validateStatus(from urlResponse: URLResponse) throws {
        if let throwError {
            throw throwError
        }
    }
}
