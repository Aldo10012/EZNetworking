import Foundation

public enum HTTPNetworkingRedirectionError: Error {
    case multipleChoices
    case movedPermanently
    case found
    case seeOther
    case notModified
    case useProxy
    case temporaryRedirect
    case permanentRedirect
    case unknown

    public init(statusCode: Int) {
        self = switch statusCode {
        case 300: .multipleChoices
        case 301: .movedPermanently
        case 302: .found
        case 303: .seeOther
        case 304: .notModified
        case 305: .useProxy
        case 307: .temporaryRedirect
        case 308: .permanentRedirect
        default: .unknown
        }
    }
}
