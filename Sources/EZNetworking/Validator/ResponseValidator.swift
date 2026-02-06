import Foundation

public protocol ResponseValidator {
    func validateStatus(from urlResponse: URLResponse) throws
}

public struct ResponseValidatorImpl: ResponseValidator {
    public init() {}

    public func validateStatus(from urlResponse: URLResponse) throws {
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.responseValidationFailed(reason: .noHTTPURLResponse)
        }
        let httpError = HTTPError(
            statusCode: httpURLResponse.statusCode,
            headers: httpURLResponse.allHeaderFields
        )

        if httpError.category == .success {
            return // successful http response (2xx) do not throw error
        }
        throw NetworkingError.responseValidationFailed(reason: .badHTTPResponse(underlying: httpError))
    }
}

public typealias URLResponseHeaders = [AnyHashable: Any]
