@testable import EZNetworking
import Testing

@Suite("Test HTTPErrorTests")
final class HTTPErrorTests {

    private static let statusCodeToCategoryMap: [Int: HTTPError.HTTPErrorCategory] = [
        100: HTTPError.HTTPErrorCategory.informational,
        200: HTTPError.HTTPErrorCategory.success,
        300: HTTPError.HTTPErrorCategory.redirection,
        400: HTTPError.HTTPErrorCategory.clientError,
        500: HTTPError.HTTPErrorCategory.serverError
    ]
    @Test("test HTTPError category given status code", arguments: zip(statusCodeToCategoryMap.keys, statusCodeToCategoryMap.values))
    func testHTTPErrorCategoryGivenStatusCode(statusCode: Int, expectedCategory: HTTPError.HTTPErrorCategory) {
        let sut = HTTPError(statusCode: statusCode, headers: [:])
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
    func testHTTPErrorDescriptionGivenStatusCode(statusCode: Int, expectedDescription: String) {
        let sut = HTTPError(statusCode: statusCode, headers: [:])
        #expect(sut.description == expectedDescription)
    }
}
