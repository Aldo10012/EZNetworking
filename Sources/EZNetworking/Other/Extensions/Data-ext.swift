import Foundation

extension Data {
    /// Create `Data` from a UTF-8 `String`.
    public init?(string: String) {
        guard let data = string.data(using: .utf8) else { return nil }
        self = data
    }

    /// Create `Data` by serializing a dictionary to JSON.
    public init?(dictionary: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else { return nil }
        self = data
    }

    /// Encode an `Encodable` value to JSON `Data`.
    public init?(encodable: some Encodable, encoder: JSONEncoder = JSONEncoder()) {
        guard let data = try? encoder.encode(encodable) else { return nil }
        self = data
    }

    /// Read file contents into `Data`.
    public init?(fileURL url: URL) {
        guard let data = try? Data(contentsOf: url) else { return nil }
        self = data
    }

    /// Create `Data` from a JSON-formatted `String`.
    public init?(jsonString: String) {
        self.init(string: jsonString)
    }

    /// Create `Data` from a Base64 encoded string.
    public init?(base64: String) {
        guard let data = Data(base64Encoded: base64) else { return nil }
        self = data
    }

    /// Create `Data` from URLComponents' percent-encoded query.
    public init?(urlComponents: URLComponents) {
        guard let query = urlComponents.percentEncodedQuery,
              let data = query.data(using: .utf8) else { return nil }
        self = data
    }

    /// Create `Data` from MultipartFormData
    public init?(multipartFormData: MultipartFormData) {
        guard let data = multipartFormData.toData() else { return nil }
        self = data
    }
}

extension Data {
    public func appending(_ data: Data?) -> Data {
        guard let dataToAppend = data else { return self }
        var copy = self
        copy.append(dataToAppend)
        return copy
    }
}
