import Foundation

public protocol Request {
    var httpMethod: HTTPMethod { get }
    var baseUrlString: String { get }
    var parameters: [HTTPParameter]? { get }
    var header: [HTTPHeader]? { get }
    var body: Data? { get }
    var timeoutInterval: TimeInterval { get }
}

public extension Request {
    var timeoutInterval: TimeInterval { 60 }
}

internal extension Request {
    func build() throws -> URLRequest {
        let request = RequestBuilder().build(httpMethod: httpMethod,
                                             baseUrlString: baseUrlString,
                                             parameters: parameters,
                                             headers: header,
                                             body: body,
                                             timeoutInterval: timeoutInterval)
        guard let unwrappedUrlRequest = request else {
            throw NetworkingError.noRequest
        }
        return unwrappedUrlRequest
    }
}
