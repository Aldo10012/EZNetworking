import Foundation

struct EZRequest: Request {
    var httpMethod: HTTPMethod
    var baseUrl: String
    var parameters: [HTTPParameter]?
    var headers: [HTTPHeader]?
    var body: HTTPBody?
    var timeoutInterval: TimeInterval
    var cachePolicy: URLRequest.CachePolicy
}
