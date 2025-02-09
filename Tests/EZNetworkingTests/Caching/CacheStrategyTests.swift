import XCTest
@testable import EZNetworking

final class CacheStrategyTests: XCTestCase {
    
    func testCachingStrategy_NetworkOnly_CachePolicy() {
        XCTAssertEqual(CacheStrategy.networkOnly.urlRequestCachePolicy, .reloadIgnoringLocalCacheData)
    }
    
    func testCachingStrategy_CacheOnly_CachePolicy() {
        XCTAssertEqual(CacheStrategy.cacheOnly.urlRequestCachePolicy, .returnCacheDataDontLoad)
    }
    
    func testCachingStrategy_NetworkWithCacheFallback_CachePolicy() {
        XCTAssertEqual(CacheStrategy.networkWithCacheFallback.urlRequestCachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func testCachingStrategy_CacheWithNetworkFallback_CachePolicy() {
        XCTAssertEqual(CacheStrategy.cacheWithNetworkFallback.urlRequestCachePolicy, .returnCacheDataElseLoad)
    }
    
    func testCachingStrategy_ValidateWithETag_CachePolicy() {
        XCTAssertEqual(CacheStrategy.validateWithETag.urlRequestCachePolicy, .useProtocolCachePolicy)
    }
}
