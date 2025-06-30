@testable import EZNetworking
import Testing

@Suite("Test HTTPSuccessStatus")
final class HTTPSuccessStatusTests {
    @Test("test StatusCode 200 Is HTTPSuccessStatus.ok")
    func testStatusCode200IsOk() {
        #expect(HTTPSuccessStatus(statusCode: 200) == .ok)
    }
    @Test("test StatusCode 201 Is HTTPSuccessStatus.created")
    func testStatusCode201IsCreated() {
        #expect(HTTPSuccessStatus(statusCode: 201) == .created)
    }
    @Test("test StatusCode 202 Is HTTPSuccessStatus.accepted")
    func testStatusCode202IsAccepted() {
        #expect(HTTPSuccessStatus(statusCode: 202) == .accepted)
    }
    @Test("test StatusCode 203 Is HTTPSuccessStatus.nonAuthoritativeInformation")
    func testStatusCode203IsNonAuthoritativeInformation() {
        #expect(HTTPSuccessStatus(statusCode: 203) == .nonAuthoritativeInformation)
    }
    @Test("test StatusCode 204 Is HTTPSuccessStatus.noContent")
    func testStatusCode204IsNoContent() {
        #expect(HTTPSuccessStatus(statusCode: 204) == .noContent)
    }
    @Test("test StatusCode 205 Is HTTPSuccessStatus.resetContent")
    func testStatusCode205IsResetContent() {
        #expect(HTTPSuccessStatus(statusCode: 205) == .resetContent)
    }
    @Test("test StatusCode 206 Is HTTPSuccessStatus.partialContent")
    func testStatusCode206IsPartialContent() {
        #expect(HTTPSuccessStatus(statusCode: 206) == .partialContent)
    }
    @Test("test StatusCode 207 Is HTTPSuccessStatus.multiStatus")
    func testStatusCode207IsMultiStatus() {
        #expect(HTTPSuccessStatus(statusCode: 207) == .multiStatus)
    }
    @Test("test StatusCode 208 Is HTTPSuccessStatus.alreadyReported")
    func testStatusCode208IsAlreadyReported() {
        #expect(HTTPSuccessStatus(statusCode: 208) == .alreadyReported)
    }
    @Test("test StatusCode 226 Is HTTPSuccessStatus.iMUsed")
    func testStatusCode226IsiMUsed() {
        #expect(HTTPSuccessStatus(statusCode: 226) == .iMUsed)
    }
    @Test("test StatusCode 210 Is HTTPSuccessStatus.unknown")
    func testStatusCode210IsUnknown() {
        #expect(HTTPSuccessStatus(statusCode: 210) == .unknown)
    }
}
