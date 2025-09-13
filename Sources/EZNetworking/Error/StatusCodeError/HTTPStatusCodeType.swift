import Foundation

// TODO: delete this file

//public enum HTTPStatusCodeType: Equatable {
//    case information(HTTPInformationalStatus)        // 1xx informational
//    case success(HTTPSuccessStatus)                  // 2xx success
//    case redirectionMessage(HTTPRedirectionStatus)   // 3xx redirect message
//    case clientSideError(HTTPClientErrorStatus)      // 4xx client errors
//    case serverSideError(HTTPServerErrorStatus)      // 5xx server errors
//    case unknown
//    
//    public static func evaluate(from statusCode: Int) -> HTTPStatusCodeType {
//        return switch statusCode {
//        case 100...199: .information(HTTPInformationalStatus(statusCode: statusCode))
//        case 200...299: .success(HTTPSuccessStatus(statusCode: statusCode))
//        case 300...399: .redirectionMessage(HTTPRedirectionStatus(statusCode: statusCode))
//        case 400...499: .clientSideError(HTTPClientErrorStatus(statusCode: statusCode))
//        case 500...599: .serverSideError(HTTPServerErrorStatus(statusCode: statusCode))
//        default: .unknown
//        }
//    }
//}
