import Foundation
import EZNetworking

struct MockURLResponseValidator: URLResponseValidator {
    var throwError: NetworkingError? = nil
    func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> DataAndStatus {
        guard let throwError else {
            guard let data else {
                throw NetworkingError.internalError(.noData)
            }
            return (data, .success(.ok))
        }
        throw throwError
    }
    
    func validateDownloadTask(url: URL?, urlResponse: URLResponse?, error: Error?) throws -> URL {
        guard let throwError else {
            guard let url else {
                throw NetworkingError.internalError(.noURL)
            }
            return url
        }
        throw throwError
    }
}
