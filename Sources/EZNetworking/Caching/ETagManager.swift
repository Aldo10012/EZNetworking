import Foundation

public protocol ETagManager {
    func addETagHeader(to request: URLRequest, for key: String) -> URLRequest
    func updateETag(from response: URLResponseHeaders, for key: String)
    
    func setETag(_ etag: String, for key: String)
    func getETag(for key: String) -> String?
    func removeETag(for key: String)
    func clearAllETags()
}

// MARK: in-memory solution

public class ETagManagerImpl: ETagManager {
    typealias ETagKey = String
    typealias ETag = String
    private var cache: [ETagKey: ETag] = [:]
    
    public init() {}
    
    public func addETagHeader(to request: URLRequest, for key: String) -> URLRequest {
        var mutableRequest = request
        if let etag = getETag(for: key) {
            mutableRequest.addValue(etag, forHTTPHeaderField: "If-None-Match")
        }
        return mutableRequest
    }
    
    public func updateETag(from response: URLResponseHeaders, for key: String) {
        if let etag = response["ETag"] as? String {
            setETag(etag, for: key)
        }
    }
    
    public func setETag(_ etag: String, for key: String) {
        cache[key] = etag
    }
    
    public func getETag(for key: String) -> String? {
        return cache[key]
    }
    
    public func removeETag(for key: String) {
        cache.removeValue(forKey: key)
    }
    
    public func clearAllETags() {
        cache.removeAll()
    }
}
