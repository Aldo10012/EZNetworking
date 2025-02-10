import Foundation

public protocol URLCacheManager {
    func clearAllCache()
    func clearCache(for request: URLRequest)
    func getCachedResponse(for request: URLRequest) throws -> CachedURLResponse
}

public class URLCacheManagerImpl: URLCacheManager {
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
    
    public func getCachedResponse(for request: URLRequest) throws -> CachedURLResponse {
        guard let cachedResponse = urlCache.cachedResponse(for: request) else {
            throw NetworkingError.internalError(.couldNotFetchCachedResponse)
        }
        return cachedResponse
    }
}
