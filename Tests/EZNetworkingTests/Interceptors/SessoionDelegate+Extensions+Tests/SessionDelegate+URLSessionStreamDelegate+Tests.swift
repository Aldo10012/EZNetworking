import XCTest
@testable import EZNetworking

final class SessionDelegateURLSessionStreamDelegateTests: XCTestCase {
    
    func testSessionDelegateReadClosedForStreamTask() {
        let streamTaskInterceptor = MockStreamTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.streamTaskInterceptor = streamTaskInterceptor
        
        delegate.urlSession(.shared, readClosedFor: mockUrlSessionStreamTask)
        
        XCTAssertTrue(streamTaskInterceptor.readClosed)
    }
    
    func testSessionDelegateWriteClosedForStreamTask() {
        let streamTaskInterceptor = MockStreamTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.streamTaskInterceptor = streamTaskInterceptor
        
        delegate.urlSession(.shared, writeClosedFor: mockUrlSessionStreamTask)
        
        XCTAssertTrue(streamTaskInterceptor.writeClosed)
    }
    
    func testSessionDelegateBetterRouteDiscoveredForStreamTask() {
        let streamTaskInterceptor = MockStreamTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.streamTaskInterceptor = streamTaskInterceptor
        
        delegate.urlSession(.shared, betterRouteDiscoveredFor: mockUrlSessionStreamTask)
        
        XCTAssertTrue(streamTaskInterceptor.betterRouteDiscovered)
    }
    
    func testSessionDelegateStreamTaskDidBecomeStreams() {
        let streamTaskInterceptor = MockStreamTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.streamTaskInterceptor = streamTaskInterceptor
        
        let inputStream = InputStream(data: Data())
        let outputStream = OutputStream(toMemory: ())
        delegate.urlSession(.shared, streamTask: mockUrlSessionStreamTask, didBecome: inputStream, outputStream: outputStream)
        
        XCTAssertTrue(streamTaskInterceptor.didBecomeStreams)
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
