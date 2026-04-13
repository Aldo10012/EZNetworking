import Foundation

public enum ResponseValidationFailureReason: Equatable, Sendable {
    case noURLResponse
    case noHTTPURLResponse
    case badHTTPResponse(underlying: HTTPResponse)

    public static func == (lhs: ResponseValidationFailureReason, rhs: ResponseValidationFailureReason) -> Bool {
        switch (lhs, rhs) {
        case (.noURLResponse, .noURLResponse),
             (.noHTTPURLResponse, .noHTTPURLResponse):
            true

        case let (.badHTTPResponse(underlying: error1), .badHTTPResponse(underlying: error2)):
            error1.statusCode == error2.statusCode

        default:
            false
        }
    }
}
