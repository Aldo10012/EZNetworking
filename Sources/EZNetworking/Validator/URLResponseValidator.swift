import Foundation

public typealias DataAndStatus = (data: Data, status: HTTPStatusCodeType.AcceptableStatus)

public protocol URLResponseValidator {
    func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> DataAndStatus
    func validateDownloadTask(url: URL?, urlResponse: URLResponse?, error: Error?) throws -> URL
}

public struct URLResponseValidatorImpl: URLResponseValidator {
    public init() {}

    public func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> DataAndStatus {
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
        let status = try validateStatusCodeAccepability(httpURLResponse.statusCode)
        return (data: data, status: status)
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
        _ = try validateStatusCodeAccepability(httpURLResponse.statusCode)
        return url
    }
    
    private func validateStatusCodeAccepability(_ statusCode: Int) throws -> HTTPStatusCodeType.AcceptableStatus {
        let statusCodeType = HTTPStatusCodeType.evaluate(from: statusCode)
        
        switch statusCodeType {
        case .information(let status):
            throw NetworkingError.information(status)
        case .success(let status):
            return HTTPStatusCodeType.AcceptableStatus.success(status)
        case .redirectionMessage(let status):
            throw NetworkingError.redirect(status)
        case .clientSideError(let error):
            throw NetworkingError.httpClientError(error)
        case .serverSideError(let error):
            throw NetworkingError.httpServerError(error)
        case .unknown:
            throw NetworkingError.internalError(.unknown)
        
        }
    }
}
