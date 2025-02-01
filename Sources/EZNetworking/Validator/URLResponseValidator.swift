import Foundation

public protocol URLResponseValidator {
    func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> Data
    func validateDownloadTask(url: URL?, urlResponse: URLResponse?, error: Error?) throws -> URL
    
    func validateNoError(_ error: Error?) throws
    func validateStatus(from urlResponse: URLResponse?) throws
    func validateData(_ data: Data?) throws -> Data
}

public struct URLResponseValidatorImpl: URLResponseValidator {
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
        try validateStatusCodeAccepability(httpURLResponse.statusCode)
    }
    
    public func validateData(_ data: Data?) throws -> Data {
        guard let data else {
            throw NetworkingError.internalError(.noData)
        }
        return data
    }



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
        try validateStatusCodeAccepability(httpURLResponse.statusCode)
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
        try validateStatusCodeAccepability(httpURLResponse.statusCode)
        return url
    }
    
    private func validateStatusCodeAccepability(_ statusCode: Int) throws {
        let statusCodeType = HTTPStatusCodeType.evaluate(from: statusCode)
        
        switch statusCodeType {
        case .information(let status):
            throw NetworkingError.information(status)
        case .success(let status):
            return
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
