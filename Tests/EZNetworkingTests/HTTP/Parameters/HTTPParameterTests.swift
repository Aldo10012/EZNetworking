import Testing
@testable import EZNetworking

@Suite("Test HTTPParameter")
final class HTTPParameterTests {
    @Test("test HTTPParameter .key and .value")
    func hTTPParameterKeyAndValue() {
        let key = "param_key"
        let value = "param_value"
        let parameter = HTTPParameter(key: key, value: value)

        #expect(parameter.key == key)
        #expect(parameter.value == value)
    }
}
