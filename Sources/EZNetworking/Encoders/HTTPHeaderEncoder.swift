import Foundation

protocol HTTPHeaderEncoder {
   func encodeHeaders(for urlRequest: inout URLRequest, with headers: [HTTPHeader])
}

struct HTTPHeaderEncoderImpl: HTTPHeaderEncoder {
    init() {}
    
    func encodeHeaders(for urlRequest: inout URLRequest, with headers: [HTTPHeader]) {
        for header in headers {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
    }
}
