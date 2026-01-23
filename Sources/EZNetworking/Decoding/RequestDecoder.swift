import Foundation

public class EZJSONDecoder: JSONDecoder, @unchecked Sendable {
    public override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        do {
            return try super.decode(type, from: data)
        } catch {
            throw NetworkingError.internalError(.couldNotParse(underlying: error))
        }
    }
}
