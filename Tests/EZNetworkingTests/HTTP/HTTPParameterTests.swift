@testable import EZNetworking
import Testing

@Suite("Test HTTPParameter")
final class HTTPParameterTests {
    
    @Test("test HTTPParameter .key and .value")
    func testHTTPParameterKeyAndValue() {
        let key = "param_key"
        let value = "param_value"
        let parameter = HTTPParameter(key: key, value: value)
        
        #expect(parameter.key == key)
        #expect(parameter.value == value)
    }
    
}
