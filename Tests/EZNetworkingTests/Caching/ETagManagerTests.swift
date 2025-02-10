import XCTest
@testable import EZNetworking

final class ETagManagerTests: XCTestCase {
    var etagManager: ETagManagerImpl!
    
    override func setUp() {
        super.setUp()
        etagManager = ETagManagerImpl()
    }
    
    override func tearDown() {
        etagManager = nil
        super.tearDown()
    }
    
    func testSetAndGetETag() {
        etagManager.setETag("etag123", for: "testKey")
        XCTAssertEqual(etagManager.getETag(for: "testKey"), "etag123")
    }
    
    func testGetETagReturnsNilForMissingKey() {
        XCTAssertNil(etagManager.getETag(for: "missingKey"))
    }
    
    func testRemoveETag() {
        etagManager.setETag("etag123", for: "testKey")
        etagManager.removeETag(for: "testKey")
        XCTAssertNil(etagManager.getETag(for: "testKey"))
    }
    
    func testClearAllETags() {
        etagManager.setETag("etag123", for: "key1")
        etagManager.setETag("etag456", for: "key2")
        etagManager.clearAllETags()
        XCTAssertNil(etagManager.getETag(for: "key1"))
        XCTAssertNil(etagManager.getETag(for: "key2"))
    }
    
    func testAddETagHeader() {
        etagManager.setETag("etag123", for: "testKey")
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request = etagManager.addETagHeader(to: request, for: "testKey")
        XCTAssertEqual(request.value(forHTTPHeaderField: "If-None-Match"), "etag123")
    }
    
    func testAddETagHeaderWithoutExistingETag() {
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let modifiedRequest = etagManager.addETagHeader(to: request, for: "testKey")
        XCTAssertNil(modifiedRequest.value(forHTTPHeaderField: "If-None-Match"))
    }
    
    func testUpdateETag() {
        let responseHeaders: [String: Any] = ["ETag": "newEtag456"]
        etagManager.updateETag(from: responseHeaders, for: "testKey")
        XCTAssertEqual(etagManager.getETag(for: "testKey"), "newEtag456")
    }
    
    func testUpdateETagWithoutETagHeader() {
        let responseHeaders: [String: Any] = ["Content-Type": "application/json"]
        etagManager.updateETag(from: responseHeaders, for: "testKey")
        XCTAssertNil(etagManager.getETag(for: "testKey"))
    }
}
