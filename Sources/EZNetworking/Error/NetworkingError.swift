import Foundation

public enum NetworkingError: Error {
    // Internal errors
    case internalError(InternalError)               /// any internal error

    // HTTP Status Code errors
    case httpClientError(HTTPClientErrorStatus)     /// 4xx status code errors
    case httpServerError(HTTPServerErrorStatus)     /// 5xx status code errors

    // URL Errors
    case urlError(URLError)                         /// any URL error
}

extension NetworkingError: Equatable {
    public static func ==(lhs: NetworkingError, rhs: NetworkingError) -> Bool {
        switch (lhs, rhs) {
        case let (.internalError(error1), .internalError(error2)):
            return error1 == error2
        
        case let (.httpClientError(error1), .httpClientError(error2)):
            return error1 == error2
        
        case let (.httpServerError(error1), .httpServerError(error2)):
            return error1 == error2

        case let (.urlError(error), .urlError(error2)):
            return error == error2

        default:
            return false
        }
    }
}
