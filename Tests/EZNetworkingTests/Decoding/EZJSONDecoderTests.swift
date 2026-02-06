@testable import EZNetworking
import Testing

@Suite("Test EZJSONDecoder")
final class EZJSONDecoderTests {
    private let sut = EZJSONDecoder()

    @Test("can decode valid mock JSON into Decodable object")
    func canDecodeValidMockJSONIntoDecodableObject() throws {
        do {
            let person = try sut.decode(Person.self, from: MockData.mockPersonJsonData)
            #expect(person.name == "John")
            #expect(person.age == 30)
        } catch {
            Issue.record("Unexpected error)")
        }
    }

    @Test("thorws error if tries to decode invalid mock json")
    func throwsErrorIfTriesToDecodeInvalidMockJSON() throws {
        do {
            _ = try sut.decode(Person.self, from: MockData.invalidMockPersonJsonData)
            Issue.record("Unexpected error)")
        } catch let error as NetworkingError {
            switch error {
            case .decodingFailed(let reason):
                switch reason {
                case let .decodingError(underlying: error):
                    #expect(Bool(true))
                case let .other(underlying: error):
                    Issue.record("expected DecodingError")
                }
            default:
                Issue.record("expected to throw error")
            }
        }
    }
}
