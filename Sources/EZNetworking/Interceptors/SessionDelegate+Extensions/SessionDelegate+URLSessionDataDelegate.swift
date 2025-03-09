import Foundation

extension SessionDelegate: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession,
                          dataTask: URLSessionDataTask,
                          willCacheResponse proposedResponse: CachedURLResponse) async -> CachedURLResponse? {
        if let interceptor = cacheInterceptor {
            return await interceptor.urlSession(session, dataTask: dataTask, willCacheResponse: proposedResponse)
        }
        return proposedResponse
    }

    public func urlSession(_ session: URLSession,
                          dataTask: URLSessionDataTask,
                          didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
        if let interceptor = dataTaskInterceptor {
            return await interceptor.urlSession(session, dataTask: dataTask, didReceive: response)
        }
        return .allow
    }

    public func urlSession(_ session: URLSession,
                          dataTask: URLSessionDataTask,
                          didReceive data: Data) {
        dataTaskInterceptor?.urlSession(session, dataTask: dataTask, didReceive: data)
    }

    public func urlSession(_ session: URLSession,
                          dataTask: URLSessionDataTask,
                          didBecome downloadTask: URLSessionDownloadTask) {
        dataTaskInterceptor?.urlSession(session, dataTask: dataTask, didBecome: downloadTask)
    }

    public func urlSession(_ session: URLSession,
                          dataTask: URLSessionDataTask,
                          didBecome streamTask: URLSessionStreamTask) {
        dataTaskInterceptor?.urlSession(session, dataTask: dataTask, didBecome: streamTask)
    }
}
