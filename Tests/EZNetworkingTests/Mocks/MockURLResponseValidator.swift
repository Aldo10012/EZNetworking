import Foundation
import EZNetworking

struct MockURLResponseValidator: URLResponseValidator {
    var throwError: NetworkingError?
    func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> Data {
        guard let throwError else {
            guard let data else {
                throw NetworkingError.noData
            }
            return data
        }
        throw throwError
    }
    
    func validateDownloadTask(url: URL?, urlResponse: URLResponse?, error: Error?) throws -> URL {
        guard let throwError else {
            guard let url else {
                throw NetworkingError.noURL
            }
            return url
        }
        throw throwError
    }
}
