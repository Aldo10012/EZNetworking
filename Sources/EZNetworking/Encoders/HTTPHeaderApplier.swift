import Foundation

struct HTTPHeaderApplier {
    private init() {}

    static func encodeHeaders(for urlRequest: inout URLRequest, with headers: [HTTPHeader]) {
        for header in headers {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
    }
}
