import Foundation

public enum NetworkingError: Error {
    case unknown
    case noURL
    case couldNotParse
    case invalidError
    case noData
    case noResponse
    case requestFailed(Error)
    case noRequest
    case noHTTPURLResponse
    case invalidImageData
    
    // MARK: - HTTP Status Code errors
    case httpError(HTTPNetworkingError)
    
    // MARK: - URL Errors
    case urlError(URLError)
}

extension NetworkingError: Equatable {
    public static func ==(lhs: NetworkingError, rhs: NetworkingError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown),
            (.noURL, .noURL),
            (.couldNotParse, .couldNotParse),
            (.invalidError, .invalidError),
            (.noData, .noData),
            (.noResponse, .noResponse),
            (.noRequest, .noRequest),
            (.noHTTPURLResponse, .noHTTPURLResponse),
            (.invalidImageData, .invalidImageData):
            return true

        case let (.httpError(statusCodeError), .httpError(statusCodeError2)):
            return statusCodeError == statusCodeError2

        case let (.urlError(error), .urlError(error2)):
            return error == error2

        case let (.requestFailed(lhsError), .requestFailed(rhsError)):
            return (lhsError as NSError) == (rhsError as NSError)

        default:
            return false
        }
    }
}
