import Foundation

public protocol ResponseValidator {
    func validateNoError(_ error: Error?) throws
    func validateStatus(from urlResponse: URLResponse?) throws
    func validateData(_ data: Data?) throws -> Data
    func validateUrl(_ url: URL?) throws -> URL
}

public struct ResponseValidatorImpl: ResponseValidator {
    public init() {}
    
    public func validateNoError(_ error: Error?) throws {
        if let error = error {
            if let urlError = error as? URLError {
                throw NetworkingError.urlError(urlError)
            }
            throw NetworkingError.internalError(.requestFailed(error))
        }
    }
    
    public func validateStatus(from urlResponse: URLResponse?) throws {
        guard let urlResponse else {
            throw NetworkingError.internalError(.noResponse)
        }
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.internalError(.noHTTPURLResponse)
        }
        try validateStatusCodeAccepability(from: httpURLResponse)
    }
    
    public func validateData(_ data: Data?) throws -> Data {
        guard let data else {
            throw NetworkingError.internalError(.noData)
        }
        return data
    }

    public func validateUrl(_ url: URL?) throws -> URL {
        guard let url else {
            throw NetworkingError.internalError(.noURL)
        }
        return url
    }

    private func validateStatusCodeAccepability(from httpURLResponse: HTTPURLResponse) throws {
        let statusCode = HTTPError(statusCode: httpURLResponse.statusCode,
                                   headers: httpURLResponse.allHeaderFields)

        if statusCode.category == .success {
            return // successful http response (2xx) do not throw error
        }
        throw NetworkingError.httpError(statusCode)
    }
}

public typealias URLResponseHeaders = [AnyHashable: Any]
