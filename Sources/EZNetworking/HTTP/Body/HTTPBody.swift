import Foundation

public typealias HTTPBody = Data

public extension HTTPBody {
    static func fromString(_ str: String) -> Data? {
        str.data(using: .utf8)
    }

    static func fromDictionary(_ dic: [String: Any]) -> Data? {
        try? JSONSerialization.data(withJSONObject: dic, options: [])
    }

    static func fromEncodable<T: Encodable>(_ encodable: T) -> Data? {
        do {
            return try JSONEncoder().encode(encodable)
        } catch {
            return nil
        }
    }

    static func fromFileURL(_ url: URL) -> Data? {
        try? Data(contentsOf: url)
    }

    static func fromJsonString(_ json: String) -> Data? {
        Data(json.utf8)
    }

    static func fromBase64(_ base64String: String) -> Data? {
        Data(base64Encoded: base64String)
    }

    static func fromURLComponents(_ components: URLComponents) -> Data? {
        guard let query = components.percentEncodedQuery else { return nil }
        return query.data(using: .utf8)
    }
}
