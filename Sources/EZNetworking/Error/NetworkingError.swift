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
    
    
    // MARK: - HTTP Status Code errors
    
    // Successful Responses (200-299)
    case ok
    
    // Redirection Messages (300-399)
    case multipleChoices
    case movedPermanently
    case found
    case seeOther
    case notModified
    case useProxy
    case temporaryRedirect
    case permanentRedirect
    
    // Client Errors (400-499)
    case badRequest
    case unauthorized
    case paymentRequired
    case forbidden
    case notFound
    case methodNotAllowed
    case notAcceptable
    case proxyAuthenticationRequired
    case requestTimeout
    case conflict
    case gone
    case lengthRequired
    case preconditionFailed
    case payloadTooLarge
    case uriTooLong
    case unsupportedMediaType
    case rangeNotSatisfiable
    case expectationFailed
    case imATeapot
    case misdirectedRequest
    case unprocessableEntity
    case locked
    case failedDependency
    case tooEarly
    case upgradeRequired
    case preconditionRequired
    case tooManyRequests
    case requestHeaderFieldsTooLarge
    case unavailableForLegalReasons
    
    // Server Errors (500-599)
    case internalServerError
    case notImplemented
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case httpVersionNotSupported
    case variantAlsoNegotiates
    case insufficientStorage
    case loopDetected
    case notExtended
    case networkAuthenticationRequired
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
                 (.ok, .ok),
                 (.multipleChoices, .multipleChoices),
                 (.movedPermanently, .movedPermanently),
                 (.found, .found),
                 (.seeOther, .seeOther),
                 (.notModified, .notModified),
                 (.useProxy, .useProxy),
                 (.temporaryRedirect, .temporaryRedirect),
                 (.permanentRedirect, .permanentRedirect),
                 (.badRequest, .badRequest),
                 (.unauthorized, .unauthorized),
                 (.paymentRequired, .paymentRequired),
                 (.forbidden, .forbidden),
                 (.notFound, .notFound),
                 (.methodNotAllowed, .methodNotAllowed),
                 (.notAcceptable, .notAcceptable),
                 (.proxyAuthenticationRequired, .proxyAuthenticationRequired),
                 (.requestTimeout, .requestTimeout),
                 (.conflict, .conflict),
                 (.gone, .gone),
                 (.lengthRequired, .lengthRequired),
                 (.preconditionFailed, .preconditionFailed),
                 (.payloadTooLarge, .payloadTooLarge),
                 (.uriTooLong, .uriTooLong),
                 (.unsupportedMediaType, .unsupportedMediaType),
                 (.rangeNotSatisfiable, .rangeNotSatisfiable),
                 (.expectationFailed, .expectationFailed),
                 (.imATeapot, .imATeapot),
                 (.misdirectedRequest, .misdirectedRequest),
                 (.unprocessableEntity, .unprocessableEntity),
                 (.locked, .locked),
                 (.failedDependency, .failedDependency),
                 (.tooEarly, .tooEarly),
                 (.upgradeRequired, .upgradeRequired),
                 (.preconditionRequired, .preconditionRequired),
                 (.tooManyRequests, .tooManyRequests),
                 (.requestHeaderFieldsTooLarge, .requestHeaderFieldsTooLarge),
                 (.unavailableForLegalReasons, .unavailableForLegalReasons),
                 (.internalServerError, .internalServerError),
                 (.notImplemented, .notImplemented),
                 (.badGateway, .badGateway),
                 (.serviceUnavailable, .serviceUnavailable),
                 (.gatewayTimeout, .gatewayTimeout),
                 (.httpVersionNotSupported, .httpVersionNotSupported),
                 (.variantAlsoNegotiates, .variantAlsoNegotiates),
                 (.insufficientStorage, .insufficientStorage),
                 (.loopDetected, .loopDetected),
                 (.notExtended, .notExtended),
                 (.networkAuthenticationRequired, .networkAuthenticationRequired):
                return true
            case let (.requestFailed(lhsError), .requestFailed(rhsError)):
                return (lhsError as NSError) == (rhsError as NSError)
            default:
                return false
            }
        }
    
    
}
