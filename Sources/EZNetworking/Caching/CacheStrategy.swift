import Foundation

public enum CacheStrategy {
    case networkOnly                      // Always fetch from network, no caching
    case cacheOnly                        // Only use cache, fail if no cache
    case networkWithCacheFallback         // Try network first, use cache on failure
    case cacheWithNetworkFallback         // Try cache first, fetch from network on failure
    case validateWithETag                 // Use ETag validation. Make request and if 304 use cached response
    
    internal var urlRequestCachePolicy: URLRequest.CachePolicy {
        return switch self {
        case .networkOnly:
            .reloadIgnoringLocalCacheData
        case .cacheOnly:
            .returnCacheDataDontLoad
        case .networkWithCacheFallback:
            .reloadIgnoringLocalAndRemoteCacheData
        case .cacheWithNetworkFallback:
            .returnCacheDataElseLoad
        case .validateWithETag:
            .useProtocolCachePolicy
        }
    }
}
