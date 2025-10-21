import Foundation

public typealias HTTPBody = Data

public extension HTTPBody {
    /// Create `Data` from a UTF-8 `String`.
    init?(string: String) {
        guard let data = string.data(using: .utf8) else { return nil }
        self = data
    }

    /// Create `Data` by serializing a dictionary to JSON.
    init?(dictionary: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else { return nil }
        self = data
    }

    /// Encode an `Encodable` value to JSON `Data`.
    init?<T: Encodable>(encodable: T, encoder: JSONEncoder = JSONEncoder()) {
        guard let data = try? encoder.encode(encodable) else { return nil }
        self = data
    }

    /// Read file contents into `Data`.
    init?(fileURL url: URL) {
        guard let data = try? Data(contentsOf: url) else { return nil }
        self = data
    }

    /// Create `Data` from a JSON-formatted `String`.
    init?(jsonString: String) {
        self.init(string: jsonString)
    }

    /// Create `Data` from a Base64 encoded string.
    init?(base64: String) {
        guard let data = Data(base64Encoded: base64) else { return nil }
        self = data
    }

    /// Create `Data` from URLComponents' percent-encoded query.
    init?(urlComponents: URLComponents) {
        guard let query = urlComponents.percentEncodedQuery,
              let data = query.data(using: .utf8) else { return nil }
        self = data
    }
}
