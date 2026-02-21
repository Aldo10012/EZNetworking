import Foundation

/// Protocol for intercepting URL cache operations
public protocol CacheInterceptor: AnyObject {
    /// Intercepts cache responses before they are cached for a specific data task.
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse) async -> CachedURLResponse?
}
