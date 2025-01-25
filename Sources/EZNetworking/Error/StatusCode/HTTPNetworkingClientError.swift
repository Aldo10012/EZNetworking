import Foundation

public enum HTTPNetworkingClientError: Error {
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
    case unknown

    public init(statusCode: Int) {
        self = switch statusCode {
        case 400: .badRequest
        case 401: .unauthorized
        case 402: .paymentRequired
        case 403: .forbidden
        case 404: .notFound
        case 405: .methodNotAllowed
        case 406: .notAcceptable
        case 407: .proxyAuthenticationRequired
        case 408: .requestTimeout
        case 409: .conflict
        case 410: .gone
        case 411: .lengthRequired
        case 412: .preconditionFailed
        case 413: .payloadTooLarge
        case 414: .uriTooLong
        case 415: .unsupportedMediaType
        case 416: .rangeNotSatisfiable
        case 417: .expectationFailed
        case 418: .imATeapot
        case 421: .misdirectedRequest
        case 422: .unprocessableEntity
        case 423: .locked
        case 424: .failedDependency
        case 425: .tooEarly
        case 426: .upgradeRequired
        case 428: .preconditionRequired
        case 429: .tooManyRequests
        case 431: .requestHeaderFieldsTooLarge
        case 451: .unavailableForLegalReasons
        default: .unknown
        }
    }
}
