import XCTest
@testable import EZNetworking

final class SessionDelegateURLSessionDownloadDelegateTests: XCTestCase {
    
    func testSessionDelegateDidFinishDownloadingTo() {
        let downloadTaskInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.downloadTaskInterceptor = downloadTaskInterceptor
        
        let mockURL = URL(fileURLWithPath: "/tmp/mockFile")
        delegate.urlSession(.shared, downloadTask: mockUrlSessionDownloadTask, didFinishDownloadingTo: mockURL)
        
        XCTAssertTrue(downloadTaskInterceptor.didFinishDownloading)
    }
    
    func testSessionDelegateDidWriteData() {
        let downloadTaskInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.downloadTaskInterceptor = downloadTaskInterceptor
        
        delegate.urlSession(.shared, downloadTask: mockUrlSessionDownloadTask, didWriteData: 100, totalBytesWritten: 200, totalBytesExpectedToWrite: 1000)
        
        XCTAssertTrue(downloadTaskInterceptor.didWriteData)
    }
    
    func testSessionDelegateDidResumeAtOffset() {
        let downloadTaskInterceptor = MockDownloadTaskInterceptor()
        let delegate = SessionDelegate()
        delegate.downloadTaskInterceptor = downloadTaskInterceptor
        
        delegate.urlSession(.shared, downloadTask: mockUrlSessionDownloadTask, didResumeAtOffset: 500, expectedTotalBytes: 1000)
        
        XCTAssertTrue(downloadTaskInterceptor.didResumeAtOffset)
    }
    
}
// MARK: mock class

private class MockDownloadTaskInterceptor: DownloadTaskInterceptor {
    var didFinishDownloading = false
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        didFinishDownloading = true
    }
    
    var didWriteData = false
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        didWriteData = true
    }
    
    var didResumeAtOffset = false
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        didResumeAtOffset = true
    }
}

// MARK: mock variables

private var mockUrlSessionDownloadTask: URLSessionDownloadTask {
    URLSession.shared.downloadTask(with: URLRequest(url: URL(string: "https://www.example.com")!))
}
