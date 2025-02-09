import Foundation

public protocol CacheManager {
    func clearAllCache()
    func clearCache(for request: URLRequest)
    func getCachedResponse(for request: URLRequest) -> CachedURLResponse?
}

public class URLCacheManager: CacheManager {
    private let urlCache: URLCache
    
    public init(urlCache: URLCache = URLCache.shared) {
        self.urlCache = urlCache
    }
    
    public func clearAllCache() {
        urlCache.removeAllCachedResponses()
    }
    
    public func clearCache(for request: URLRequest) {
        urlCache.removeCachedResponse(for: request)
    }
    
    public func getCachedResponse(for request: URLRequest) -> CachedURLResponse? {
        return urlCache.cachedResponse(for: request)
    }
}
