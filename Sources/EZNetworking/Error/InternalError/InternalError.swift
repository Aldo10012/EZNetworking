import Foundation

public enum InternalError: Error {
    case noURL
    case couldNotParse
    case invalidError
    case noData
    case noResponse
    case requestFailed(Error)
    case noRequest
    case noHTTPURLResponse
    case invalidImageData
    case unknown
}

extension InternalError: Equatable {
    public static func ==(lhs: InternalError, rhs: InternalError) -> Bool {
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
            
        case let (.requestFailed(lhsError), .requestFailed(rhsError)):
            return (lhsError as NSError) == (rhsError as NSError)
        
        default:
            return false
        }
    }
}
