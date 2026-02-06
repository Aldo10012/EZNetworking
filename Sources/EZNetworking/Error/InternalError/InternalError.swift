import Foundation

public enum InternalError: Error {
    // URL error
    case noURL
    case invalidURL
    case invalidScheme(String?)
    case missingHost

    case couldNotParse(underlying: Error)
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
    public static func == (lhs: InternalError, rhs: InternalError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown),
             (.noURL, .noURL),
             (.invalidURL, .invalidURL),
             (.missingHost, .missingHost),
             (.noData, .noData),
             (.noResponse, .noResponse),
             (.noRequest, .noRequest),
             (.noHTTPURLResponse, .noHTTPURLResponse),
             (.invalidImageData, .invalidImageData),
             (.lostReferenceOfSelf, .lostReferenceOfSelf):
            true

        case let (.requestFailed(lhsError), .requestFailed(rhsError)),
             let (.couldNotParse(underlying: lhsError), .couldNotParse(underlying: rhsError)):
            (lhsError as NSError) == (rhsError as NSError)

        case let (.invalidScheme(lhsScheme), .invalidScheme(rhsScheme)):
            lhsScheme == rhsScheme

        default:
            false
        }
    }
}
