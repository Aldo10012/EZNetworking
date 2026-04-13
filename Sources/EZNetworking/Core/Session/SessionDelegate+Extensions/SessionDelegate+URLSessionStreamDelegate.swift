import Foundation

extension SessionDelegate: URLSessionStreamDelegate {
    public func urlSession(
        _ session: URLSession,
        readClosedFor streamTask: URLSessionStreamTask
    ) {
        streamTaskInterceptor?.urlSession(session, readClosedFor: streamTask)
    }

    public func urlSession(
        _ session: URLSession,
        writeClosedFor streamTask: URLSessionStreamTask
    ) {
        streamTaskInterceptor?.urlSession(session, writeClosedFor: streamTask)
    }

    public func urlSession(
        _ session: URLSession,
        betterRouteDiscoveredFor streamTask: URLSessionStreamTask
    ) {
        streamTaskInterceptor?.urlSession(session, betterRouteDiscoveredFor: streamTask)
    }

    public func urlSession(
        _ session: URLSession,
        streamTask: URLSessionStreamTask,
        didBecome inputStream: InputStream,
        outputStream: OutputStream
    ) {
        streamTaskInterceptor?.urlSession(session, streamTask: streamTask, didBecome: inputStream, outputStream: outputStream)
    }
}
