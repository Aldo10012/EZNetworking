import UIKit
import XCTest
@testable import EZNetworking

final class RequestPerformerTests: XCTestCase {

    // MARK: Unit tests for perform using Completion Handler

    func testPerformWithCompletionHandlerDoesDecodePerson() {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        var didExecute = false
        sut.perform(request: request, decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success(let person):
                XCTAssertEqual(person.name, "John")
                XCTAssertEqual(person.age, 30)
            case .failure:
                XCTFail()
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithErrorFails() {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: NetworkingError.forbidden
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.forbidden)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        var didExecute = false
        sut.perform(request: request, decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.forbidden)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithBadStatusCodeFails() {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 400),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.badRequest)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        var didExecute = false
        sut.perform(request: request, decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.badRequest)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithInvalidData() {
        let urlSession = MockURLSession(
            data: invalidMockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        var didExecute = false
        sut.perform(request: request, decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.couldNotParse)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithNilData() {
        let urlSession = MockURLSession(
            data: nil,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        var didExecute = false
        sut.perform(request: request, decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noData)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithNilResponse() {
        let urlSession = MockURLSession(
            data: invalidMockPersonJsonData,
            urlResponse: nil,
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        var didExecute = false
        sut.perform(request: request, decodeTo: Person.self) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.couldNotParse)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    // MARK: Unit tests for perform using Completion Handler without Decodable response
    
    func testPerformWithCompletionHandlerWithoutDecodableDoesDecodePerson() {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = MockURLResponseValidator(throwError: nil)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        var didExecute = false
        sut.perform(request: request) { result in
            didExecute = true
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail()
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithErrorFails() {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 200),
            error: NetworkingError.forbidden
        )
        let validator = MockURLResponseValidator(throwError: NetworkingError.forbidden)
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        var didExecute = false
        sut.perform(request: request) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.forbidden)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithBadStatusCodeFails() {
        let urlSession = MockURLSession(
            data: mockPersonJsonData,
            urlResponse: buildResponse(statusCode: 400),
            error: nil
        )
        let validator = URLResponseValidatorImpl()
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        var didExecute = false
        sut.perform(request: request) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.badRequest)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithNilData() {
        let urlSession = MockURLSession(
            data: nil,
            urlResponse: buildResponse(statusCode: 200),
            error: nil
        )
        let validator = URLResponseValidatorImpl()
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        var didExecute = false
        sut.perform(request: request) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noData)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testPerformWithCompletionHandlerWithoutDecodableWithNilResponse() {
        let urlSession = MockURLSession(
            data: invalidMockPersonJsonData,
            urlResponse: nil,
            error: nil
        )
        let validator = URLResponseValidatorImpl()
        let decoder = RequestDecoder()
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator, requestDecoder: decoder)
        
        guard let request = RequestBuilder().build(httpMethod: .GET, urlString: "https://www.example.com", parameters: nil) else {
            XCTFail()
            return
        }
        
        var didExecute = false
        sut.perform(request: request) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noResponse)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    // MARK: Unit tests for downloadFile
    
    func testDownloadFileSuccess() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let urlSession = MockURLSession(url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let sut = RequestPerformer(urlSession: urlSession,
                                   urlResponseValidator: MockURLResponseValidator(),
                                   requestDecoder: RequestDecoder())
        
        var didExecute = false
        sut.downloadFile(url: testURL) { result in
            didExecute = true
            switch result {
            case .success(let localURL):
                XCTAssertEqual(localURL.absoluteString, "file:///tmp/test.pdf")
            case .failure:
                XCTFail()
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testDownloadFileFailsIfValidatorThrowsAnyError() {
        let testURL = URL(string: "https://example.com/example.pdf")!
        let validator = MockURLResponseValidator(throwError: .conflict)
        let urlSession = MockURLSession(url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let sut = RequestPerformer(urlSession: urlSession,
                                   urlResponseValidator: validator,
                                   requestDecoder: RequestDecoder())
        
        var didExecute = false
        sut.downloadFile(url: testURL) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.conflict)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    // MARK: - downloadImage
    
    func testDownloadImageSuccess() {
        let testURL = URL(string: "https://i.natgeofe.com/n/4f5aaece-3300-41a4-b2a8-ed2708a0a27c/domestic-dog_thumb_square.jpg")!
        let urlSession = MockURLSession(data: mockPersonJsonData,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let validator = MockURLResponseValidator(throwError: nil)
        let sut = RequestPerformer(urlSession: urlSession, urlResponseValidator: validator)
        
        var didExecute = false
        sut.downloadImage(url: testURL) { result in
            didExecute = true
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure(let error):
                if error == NetworkingError.invalidImageData {
                    XCTAssertTrue(true, "mock data was just not suited to generate a UIImage")
                } else {
                    XCTFail()
                }
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    func testDownloadImageFailsWhenValidatorThrowsAnyError() {
        let testURL = URL(string: "https://i.natgeofe.com/n/4f5aaece-3300-41a4-b2a8-ed2708a0a27c/domestic-dog_thumb_square.jpg")!
        let urlSession = MockURLSession(url: testURL,
                                        urlResponse: buildResponse(statusCode: 200),
                                        error: nil)
        let validator = MockURLResponseValidator(throwError: .conflict)
        let sut = RequestPerformer(urlSession: urlSession,
                                   urlResponseValidator: validator,
                                   requestDecoder: RequestDecoder())
        
        var didExecute = false
        sut.downloadImage(url: testURL) { result in
            didExecute = true
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.conflict)
            }
        }.resume()
        XCTAssertTrue(didExecute)
    }
    
    
    private func buildResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)!
    }

}
