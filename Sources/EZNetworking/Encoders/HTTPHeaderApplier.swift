import Foundation

struct HTTPHeaderApplier {
    private init() {}

    static func apply(_ headers: [HTTPHeader], to urlRequest: inout URLRequest) {
        for header in headers {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
    }
}
