import Foundation

/// Protocol for intercepting URL cache operations
public protocol CacheInterceptor: AnyObject {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping @Sendable (CachedURLResponse?) -> Void)
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse) async -> CachedURLResponse?
}
