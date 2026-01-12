import Foundation

public enum InternalError: Error {
    // URL error
    case noURL
    case invalidURL
    case invalidScheme(String?)
    case missingHost
    
    case couldNotParse
    case invalidError
    case noData
    case noResponse
    case requestFailed(Error)
    case noRequest
    case noHTTPURLResponse
    case invalidImageData
    case lostReferenceOfSelf
    case unknown
}

extension InternalError: Equatable {
    public static func ==(lhs: InternalError, rhs: InternalError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown),
            (.noURL, .noURL),
            (.invalidURL, .invalidURL),
            (.missingHost, .missingHost),
            (.couldNotParse, .couldNotParse),
            (.invalidError, .invalidError),
            (.noData, .noData),
            (.noResponse, .noResponse),
            (.noRequest, .noRequest),
            (.noHTTPURLResponse, .noHTTPURLResponse),
            (.invalidImageData, .invalidImageData),
            (.lostReferenceOfSelf, .lostReferenceOfSelf):
            return true
            
        case let (.requestFailed(lhsError), .requestFailed(rhsError)):
            return (lhsError as NSError) == (rhsError as NSError)
        
        case let (.invalidScheme(lhsScheme), .invalidScheme(rhsScheme)):
            return lhsScheme == rhsScheme
        
        default:
            return false
        }
    }
}
