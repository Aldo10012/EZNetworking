import Foundation

extension HTTPURLResponse {
    var networkingError: NetworkingError {
        switch statusCode {
        
        // Successful Responses (200-299)
        case 200...299: return .ok
        
        // Redirection Messages (300-399)
        case 300: return .multipleChoices
        case 301: return .movedPermanently
        case 302: return .found
        case 303: return .seeOther
        case 304: return .notModified
        case 305: return .useProxy
        case 307: return .temporaryRedirect
        case 308: return .permanentRedirect
        
        // Client Errors (400-499)
        case 400: return .badRequest
        case 401: return .unauthorized
        case 402: return .paymentRequired
        case 403: return .forbidden
        case 404: return .notFound
        case 405: return .methodNotAllowed
        case 406: return .notAcceptable
        case 407: return .proxyAuthenticationRequired
        case 408: return .requestTimeout
        case 409: return .conflict
        case 410: return .gone
        case 411: return .lengthRequired
        case 412: return .preconditionFailed
        case 413: return .payloadTooLarge
        case 414: return .uriTooLong
        case 415: return .unsupportedMediaType
        case 416: return .rangeNotSatisfiable
        case 417: return .expectationFailed
        case 418: return .imATeapot
        case 421: return .misdirectedRequest
        case 422: return .unprocessableEntity
        case 423: return .locked
        case 424: return .failedDependency
        case 425: return .tooEarly
        case 426: return .upgradeRequired
        case 428: return .preconditionRequired
        case 429: return .tooManyRequests
        case 431: return .requestHeaderFieldsTooLarge
        case 451: return .unavailableForLegalReasons
        
        // Server Errors (500-599)
        case 500: return .internalServerError
        case 501: return .notImplemented
        case 502: return .badGateway
        case 503: return .serviceUnavailable
        case 504: return .gatewayTimeout
        case 505: return .httpVersionNotSupported
        case 506: return .variantAlsoNegotiates
        case 507: return .insufficientStorage
        case 508: return .loopDetected
        case 510: return .notExtended
        case 511: return .networkAuthenticationRequired
        
        // Unknown or Unhandled Status Code
        default: return .unknown
        }
    }
}
