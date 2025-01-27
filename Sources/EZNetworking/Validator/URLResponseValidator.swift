import Foundation

public protocol URLResponseValidator {
    func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> Data
    func validateDownloadTask(url: URL?, urlResponse: URLResponse?, error: Error?) throws -> URL
}

public struct URLResponseValidatorImpl: URLResponseValidator {
    public init() {}

    public func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> Data {
        if let error = error {
            if let urlError = error as? URLError {
                throw NetworkingError.urlError(urlError)
            }
            throw NetworkingError.internalError(.requestFailed(error))
        }
        guard let data else {
            throw NetworkingError.internalError(.noData)
        }
        guard let urlResponse else {
            throw NetworkingError.internalError(.noResponse)
        }
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.internalError(.noHTTPURLResponse)
        }
        try validateStatusCode(httpURLResponse.statusCode)
        return data
    }

    public func validateDownloadTask(url: URL?, urlResponse: URLResponse?, error: Error?) throws -> URL {
        if let error = error {
            if let urlError = error as? URLError {
                throw NetworkingError.urlError(urlError)
            }
            throw NetworkingError.internalError(.requestFailed(error))
        }
        guard let url else {
            throw NetworkingError.internalError(.noURL)
        }
        guard let urlResponse else {
            throw NetworkingError.internalError(.noResponse)
        }
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.internalError(.noHTTPURLResponse)
        }
        try validateStatusCode(httpURLResponse.statusCode)
        return url
    }
    
    private func validateStatusCode(_ statusCode: Int) throws {
        switch HTTPStatusCodeType.evaluate(from: statusCode) {
        case .ok:
            return
        case .redirectionMessage(let error):
            throw NetworkingError.httpRedirectError(error)
        case .clientSideError(let error):
            throw NetworkingError.httpClientError(error)
        case .serverSideError(let error):
            throw NetworkingError.httpServerError(error)
        case .unknown:
            throw NetworkingError.internalError(.unknown)
        }
    }
}
