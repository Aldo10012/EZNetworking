import Foundation

public enum ResponseValidationFailureReason: Equatable, Sendable {
    case noHTTPURLResponse
    case badHTTPResponse(underlying: HTTPError)

    public static func == (lhs: ResponseValidationFailureReason, rhs: ResponseValidationFailureReason) -> Bool {
        switch (lhs, rhs) {
        case (.noHTTPURLResponse, .noHTTPURLResponse):
            true

        case let (.badHTTPResponse(underlying: error1), .badHTTPResponse(underlying: error2)):
            error1.statusCode == error2.statusCode

        default:
            false
        }
    }
}
