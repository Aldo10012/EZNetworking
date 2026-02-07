@testable import EZNetworking
import Testing

@Suite("Test HTTPResponse")
final class HTTPResponseTests {
    private static let statusCodeToCategoryMap: [Int: HTTPResponse.HTTPErrorCategory] = [
        100: HTTPResponse.HTTPErrorCategory.informational,
        200: HTTPResponse.HTTPErrorCategory.success,
        300: HTTPResponse.HTTPErrorCategory.redirection,
        400: HTTPResponse.HTTPErrorCategory.clientError,
        500: HTTPResponse.HTTPErrorCategory.serverError
    ]
    @Test("test HTTPError category given status code", arguments: zip(statusCodeToCategoryMap.keys, statusCodeToCategoryMap.values))
    func hTTPErrorCategoryGivenStatusCode(statusCode: Int, expectedCategory: HTTPResponse.HTTPErrorCategory) {
        let sut = HTTPResponse(statusCode: statusCode, headers: [:])
        #expect(sut.category == expectedCategory)
    }

    private static let statusCodeToDescriptionMap: [Int: String] = [
        100: "Continue",
        200: "OK",
        300: "Multiple Choices",
        400: "Bad Request",
        500: "Internal Server Error"
    ]
    @Test("test HTTPError description given status code", arguments: zip(statusCodeToDescriptionMap.keys, statusCodeToDescriptionMap.values))
    func hTTPErrorDescriptionGivenStatusCode(statusCode: Int, expectedDescription: String) {
        let sut = HTTPResponse(statusCode: statusCode, headers: [:])
        #expect(sut.description == expectedDescription)
    }
}
