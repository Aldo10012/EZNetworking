import Foundation

public enum NetworkingError: Error {
    // Internal errors
    case internalError(InternalError)               /// any internal error

    // HTTP Status Code errors
    case information(HTTPInformationalStatus, URLResponseHeaders)       /// 1xx status code errors
    case redirect(HTTPRedirectionStatus, URLResponseHeaders)            /// 3xx status code errors
    case httpClientError(HTTPClientErrorStatus, URLResponseHeaders)     /// 4xx status code errors
    case httpServerError(HTTPServerErrorStatus, URLResponseHeaders)     /// 5xx status code errors

    // URL Errors
    case urlError(URLError)                         /// any URL error
}

extension NetworkingError: Equatable {
    public static func ==(lhs: NetworkingError, rhs: NetworkingError) -> Bool {
        switch (lhs, rhs) {
        case let (.internalError(error1), .internalError(error2)):
            return error1 == error2
        
        case let (.information(error1, _), .information(error2, _)):
            return error1 == error2
            
        case let (.redirect(error1, _), .redirect(error2, _)):
            return error1 == error2

        case let (.httpClientError(error1, _), .httpClientError(error2, _)):
            return error1 == error2
        
        case let (.httpServerError(error1, _), .httpServerError(error2, _)):
            return error1 == error2

        case let (.urlError(error), .urlError(error2)):
            return error == error2

        default:
            return false
        }
    }
}
