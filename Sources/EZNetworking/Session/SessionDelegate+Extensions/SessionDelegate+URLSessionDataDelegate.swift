import Foundation

extension SessionDelegate: URLSessionDataDelegate {
    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        willCacheResponse proposedResponse: CachedURLResponse
    ) async -> CachedURLResponse? {
        await cacheInterceptor?.urlSession(session, dataTask: dataTask, willCacheResponse: proposedResponse) ?? proposedResponse
    }

    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse
    ) async -> URLSession.ResponseDisposition {
        await dataTaskInterceptor?.urlSession(session, dataTask: dataTask, didReceive: response) ?? .allow
    }

    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        dataTaskInterceptor?.urlSession(session, dataTask: dataTask, didReceive: data)
    }

    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didBecome downloadTask: URLSessionDownloadTask
    ) {
        dataTaskInterceptor?.urlSession(session, dataTask: dataTask, didBecome: downloadTask)
    }

    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didBecome streamTask: URLSessionStreamTask
    ) {
        dataTaskInterceptor?.urlSession(session, dataTask: dataTask, didBecome: streamTask)
    }
}
