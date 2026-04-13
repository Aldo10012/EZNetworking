@testable import EZNetworking
import Foundation
import Testing

@Suite("Test SessionDelegateURLSessionStreamDelegate")
final class SessionDelegateURLSessionStreamDelegateTests {
    @Test("test SessionDelegate ReadClosedForStreamTask")
    func sessionDelegateReadClosedForStreamTask() {
        let streamTaskInterceptor = MockStreamTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.streamTaskInterceptor = streamTaskInterceptor

        delegate.urlSession(.shared, readClosedFor: mockUrlSessionStreamTask)

        #expect(streamTaskInterceptor.readClosed)
    }

    @Test("test SessionDelegate WriteClosedForStreamTask")
    func sessionDelegateWriteClosedForStreamTask() {
        let streamTaskInterceptor = MockStreamTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.streamTaskInterceptor = streamTaskInterceptor

        delegate.urlSession(.shared, writeClosedFor: mockUrlSessionStreamTask)

        #expect(streamTaskInterceptor.writeClosed)
    }

    @Test("test SessionDelegate BetterRouteDiscoveredForStreamTask")
    func sessionDelegateBetterRouteDiscoveredForStreamTask() {
        let streamTaskInterceptor = MockStreamTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.streamTaskInterceptor = streamTaskInterceptor

        delegate.urlSession(.shared, betterRouteDiscoveredFor: mockUrlSessionStreamTask)

        #expect(streamTaskInterceptor.betterRouteDiscovered)
    }

    @Test("test SessionDelegate StreamTaskDidBecomeStreams")
    func sessionDelegateStreamTaskDidBecomeStreams() {
        let streamTaskInterceptor = MockStreamTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.streamTaskInterceptor = streamTaskInterceptor

        let inputStream = InputStream(data: Data())
        let outputStream = OutputStream(toMemory: ())
        delegate.urlSession(.shared, streamTask: mockUrlSessionStreamTask, didBecome: inputStream, outputStream: outputStream)

        #expect(streamTaskInterceptor.didBecomeStreams)
    }
}

// MARK: mock classes

private class MockStreamTaskInterceptor: StreamTaskInterceptor {
    var readClosed = false
    func urlSession(_ session: URLSession, readClosedFor streamTask: URLSessionStreamTask) {
        readClosed = true
    }

    var writeClosed = false
    func urlSession(_ session: URLSession, writeClosedFor streamTask: URLSessionStreamTask) {
        writeClosed = true
    }

    var betterRouteDiscovered = false
    func urlSession(_ session: URLSession, betterRouteDiscoveredFor streamTask: URLSessionStreamTask) {
        betterRouteDiscovered = true
    }

    var didBecomeStreams = false
    func urlSession(_ session: URLSession, streamTask: URLSessionStreamTask, didBecome inputStream: InputStream, outputStream: OutputStream) {
        didBecomeStreams = true
    }
}

// MARK: mock variables

private var mockUrlSessionStreamTask: URLSessionStreamTask {
    URLSession.shared.streamTask(withHostName: "", port: 0)
}
