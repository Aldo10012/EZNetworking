import Foundation

public protocol Request {
    var httpMethod: HTTPMethod { get }
    var baseUrlString: String { get }
    var parameters: [HTTPParameter]? { get }
    var headers: [HTTPHeader]? { get }
    var body: Data? { get }
    var timeoutInterval: TimeInterval { get }
    var urlRequest: URLRequest? { get }
}

public extension Request {
    var timeoutInterval: TimeInterval { 60 }

    var urlRequest: URLRequest? {
        guard let url = URL(string: baseUrlString) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        request.timeoutInterval = timeoutInterval

        if let parameters = parameters {
            try? HTTPParameterEncoderImpl().encodeParameters(for: &request, with: parameters)
        }

        if let headers = headers {
            HTTPHeaderEncoderImpl().encodeHeaders(for: &request, with: headers)
        }

        return request
    }
}

internal struct EZRequest: Request {
    var httpMethod: HTTPMethod
    var baseUrlString: String
    var parameters: [HTTPParameter]?
    var headers: [HTTPHeader]?
    var body: Data?
    var timeoutInterval: TimeInterval
}
