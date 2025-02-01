import Foundation
import EZNetworking

struct MockURLResponseValidator: URLResponseValidator {
    
    func validateNoError(_ error: (any Error)?) throws {
        if let throwError = throwError {
            throw throwError
        }
    }
    
    func validateStatus(from urlResponse: URLResponse?) throws {
        if let throwError = throwError {
            throw throwError
        }
    }
    
    func validateData(_ data: Data?) throws -> Data {
        if let throwError = throwError {
            throw throwError
        }
        guard let data else {
            throw NetworkingError.internalError(.noData)
        }
        return data
    }
    
    func validateUrl(_ url: URL?) throws -> URL {
        if let throwError = throwError {
            throw throwError
        }
        guard let url else {
            throw NetworkingError.internalError(.noURL)
        }
        return url
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
