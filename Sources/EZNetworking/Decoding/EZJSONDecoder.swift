import Foundation

public class EZJSONDecoder: JSONDecoder, @unchecked Sendable {
    override public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        do {
            return try super.decode(type, from: data)
        } catch let error as DecodingError {
            throw NetworkingError.decodingFailed(reason: .decodingError(underlying: error))
        } catch {
            throw NetworkingError.decodingFailed(reason: .other(underlying: error.asSendableError))
        }
    }
}
