@testable import EZNetworking
import Testing

@Suite("Test decoder")
final class decoderTests {
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
            #expect(error == NetworkingError.internalError(.couldNotParse))
        }
    }
}
