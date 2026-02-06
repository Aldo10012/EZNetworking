import Foundation

public protocol ResponseValidator {
    func validateStatus(from urlResponse: URLResponse) throws
}

public struct ResponseValidatorImpl: ResponseValidator {
    public init() {}

    public func validateStatus(from urlResponse: URLResponse) throws {
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.internalError(.noHTTPURLResponse)
        }
        let statusCode = HTTPError(
            statusCode: httpURLResponse.statusCode,
            headers: httpURLResponse.allHeaderFields
        )

        if statusCode.category == .success {
            return // successful http response (2xx) do not throw error
        }
        throw NetworkingError.httpError(statusCode)
    }
}

public typealias URLResponseHeaders = [AnyHashable: Any]
