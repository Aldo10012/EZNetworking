import Foundation

public protocol URLResponseValidator {
    func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> Data
}

public struct URLResponseValidatorImpl: URLResponseValidator {
    public init() {}

    public func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> Data {
        guard let data else {
            throw NetworkingError.noData
        }
        guard let urlResponse else {
            throw NetworkingError.noResponse
        }
        if let error = error {
            throw NetworkingError.requestFailed(error)
        }
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.noHTTPURLResponse
        }
        
        let errorResponse = httpURLResponse.networkingError
        if case .ok = errorResponse {
            return data
        } else {
            throw errorResponse
        }
    }
}
