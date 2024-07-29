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
            throw NetworkingError.requestFailed(error)
        }
        guard let data else {
            throw NetworkingError.noData
        }
        guard let urlResponse else {
            throw NetworkingError.noResponse
        }
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.noHTTPURLResponse
        }
        if let httpError = HTTPNetworkingError.fromStatusCode(httpURLResponse.statusCode) {
            throw NetworkingError.httpError(httpError)
        }
        return data
    }

    public func validateDownloadTask(url: URL?, urlResponse: URLResponse?, error: Error?) throws -> URL {
        if let error = error {
            if let urlError = error as? URLError {
                throw NetworkingError.urlError(urlError)
            }
            throw NetworkingError.requestFailed(error)
        }
        guard let url else {
            throw NetworkingError.noURL
        }
        guard let urlResponse else {
            throw NetworkingError.noResponse
        }
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.noHTTPURLResponse
        }
        if let httpError = HTTPNetworkingError.fromStatusCode(httpURLResponse.statusCode) {
            throw NetworkingError.httpError(httpError)
        }
        return url
    }
}
