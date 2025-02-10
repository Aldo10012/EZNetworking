import XCTest
@testable import EZNetworking

final class CacheManagerTests: XCTestCase {
    func testSpyURLCache_clearAllCache_doesRemoveAllCachedResponses() {
        let cache = SpyURLCache()
        let sut = URLCacheManagerImpl(urlCache: cache)
        sut.clearAllCache()
        XCTAssertTrue(cache.didRemoveAllCachedResponses)
    }
    
    func testSpyURLCache_clearCache_doesRemoveRemoveCachedResponse() {
        let cache = SpyURLCache()
        let sut = URLCacheManagerImpl(urlCache: cache)
        sut.clearCache(for: URLRequest(url: URL(string: "https://www.example.com")!))
        XCTAssertTrue(cache.didRemoveCachedResponse)
    }
    
    func testSpyURLCache_getCachedResponse_doesRemoveAllCachedResponses() throws {
        let cache = SpyURLCache()
        let sut = URLCacheManagerImpl(urlCache: cache)
        _ = try sut.getCachedResponse(for: URLRequest(url: URL(string: "https://www.example.com")!))
        XCTAssertTrue(cache.didCachedResponse)
    }
}

private class SpyURLCache: URLCache, @unchecked Sendable {
    var didRemoveAllCachedResponses = false
    override func removeAllCachedResponses() {
        didRemoveAllCachedResponses = true
    }
    
    var didRemoveCachedResponse = false
    override func removeCachedResponse(for: URLRequest) {
        didRemoveCachedResponse = true
    }
    
    var didCachedResponse = false
    override func cachedResponse(for: URLRequest) -> CachedURLResponse? {
        didCachedResponse = true
        return CachedURLResponse()
    }
}
