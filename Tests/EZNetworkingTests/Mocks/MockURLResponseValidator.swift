import Foundation
import EZNetworking

struct MockURLResponseValidator: URLResponseValidator {
    func validateNoError(_ error: (any Error)?) throws {
        
    }
    
    func validateStatus(from urlResponse: URLResponse?) throws {
        
    }
    
    func validateData(_ data: Data?) throws -> Data {
        guard let data else {
            throw NetworkingError.internalError(.noData)
        }
        return data
    }
    
    var throwError: NetworkingError? = nil
    func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> Data {
        guard let throwError else {
            guard let data else {
                throw NetworkingError.internalError(.noData)
            }
            return data
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
