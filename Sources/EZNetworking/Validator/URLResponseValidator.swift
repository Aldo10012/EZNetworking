import Foundation

public protocol URLResponseValidator {
    func validate(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> Data
    func validateDownloadTask(url: URL?, urlResponse: URLResponse?, error: Error?) throws -> URL
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
            switch error {
            case URLError.notConnectedToInternet:
                throw NetworkingError.noConnection
            default:
                throw NetworkingError.requestFailed(error)
            }
        }
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.noHTTPURLResponse
        }
        
        if let errorResponse = httpURLResponse.networkingError {
            throw errorResponse
        }

        return data
    }
    
    public func validateDownloadTask(url: URL?, urlResponse: URLResponse?, error: Error?) throws -> URL {
        guard let url else {
            throw NetworkingError.noURL
        }
        guard let urlResponse else {
            throw NetworkingError.noResponse
        }
        if let error = error {
            switch error {
            case URLError.notConnectedToInternet:
                throw NetworkingError.noConnection
            default:
                throw NetworkingError.requestFailed(error)
            }
        }
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.noHTTPURLResponse
        }
        
        if let errorResponse = httpURLResponse.networkingError {
            throw errorResponse
        }

        return url        
    }
}
