# EZNetworking

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%2015.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

EZNetworking is a powerful, lightweight Swift networking library that simplifies API interactions in your iOS applications. Built with modern Swift features, it provides an intuitive interface for making HTTP requests, handling responses, and managing network operations.

## Key Features 🚀

- **Modern Swift Support**: Built with Swift 5.9 and iOS 15.0+
- **Async/Await Integration**: First-class support for Swift concurrency
- **Type-Safe Networking**: Strong typing for requests and responses
- **Flexible Request Building**: Multiple approaches to creating requests
- **Comprehensive Interceptors**: Full request/response pipeline control
- **Built-in Caching**: Efficient response caching system
- **File Download**: Easy-to-use file downloader
- **File Upload**: Easy-to-use file uploader
- **Data Upload**: Easy-to-use data uploader
- **WebSocket**: Real-time, bi-directional client-to-server communication
- **Server-Sent Events**: Lightweight, server-to-client streaming with automatic reconnection
- **Extensive Testing**: 100% unit test coverage

## Table of Contents 📑

- [Installation](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#installation-)
- [Quick Start Guide](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#quick-start-guide-)

<!-- NEW -->

- Usage
  - HTTP Components - [HTTP Method](Documentation/01_httpComponents.md#http-methods), [HTTP Query Parameter](Documentation/01_httpComponents.md#query-parameters), [HTTP Header](Documentation/01_httpComponents.md#headers), [HTTP Body](Documentation/01_httpComponents.md#request-body), [Timeout](Documentation/01_httpComponents.md#timeout-and-cache), [Cache](Documentation/01_httpComponents.md#timeout-and-cache)
  - How to make a request - [RequestFactory](Documentation/02_howToMakeARequest.md#using-requestfactory), [RequestBuilder](Documentation/02_howToMakeARequest.md#using-requestbuilder), [Request protocol](Documentation/02_howToMakeARequest.md#request-protocol)
  - How to perform a request - [Performing a Request](Documentation/03_howToPerformARequest.md#performing-a-request), [Error handling](Documentation/03_howToPerformARequest.md#error-handling)
  - Large Data - [File Download](Documentation/04_largeData.md#file-download), [Data Upload](Documentation/04_largeData.md#data-upload), [File Upload](Documentation/04_largeData.md#file-upload), [Multipart-form Upload](Documentation/04_largeData.md#multipart-form-upload)
  - Live Communication - [server-sent-event](Documentation/05_liveConnumication.md#server-sent-events), [websocket](Documentation/05_liveConnumication.md#websocket)
  - Session Management - [Session](), [SessionDelegate](), [Interceptors]()

<!-- OLD -->

- [Building Requests](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#building-requests-%EF%B8%8F)
  - [Using RequestFactory](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#using-requestfactory)
  - [Using RequestBuilder](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#using-requestbuilder)
  - [Request Protocol](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#request-protocol)
- [Request Components](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#request-components-)
  - [HTTP Methods](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#http-methods)
  - [Query Parameters](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#query-parameters)
  - [Headers](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#headers)
  - [Authorization](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#authorization)
  - [Request Body](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#request-body)
  - [Timeout & Cache](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#timeout-and-cache)
- [Making Network Calls](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#making-network-calls-)
  - [Async/Await](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#asyncawait-usage)
  - [Completion Handlers](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#completion-handlers)
  - [Task Control](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#task-control)
  - [Combine Publishers](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#publishers)
- [Download Features](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#download-features-)
  - [File Downloads](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#file-downloads)
- [Upload Features](https://github.com/Aldo10012/EZNetworking/?tab=readme-ov-file#upload-features)
  - [Date Upload](https://github.com/Aldo10012/EZNetworking/?tab=readme-ov-file#uploading-raw-data)
  - [File Upload](https://github.com/Aldo10012/EZNetworking/blob/main/README.md#uploading-file)
  - [Multipart-form Upload](https://github.com/Aldo10012/EZNetworking/blob/main/README.md#uploading-multipart-form-data)
- [Web Socket](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#web-socket)
    - [How to initialize](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-initialize)
    - [How to connect](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-connect)
    - [How to disconnect](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-disconnect)
    - [How to terminate](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-terminate)
    - [How to send a message](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-send-messages)
    - [How to receive messages](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-receive-messages)
    - [How to observe state](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-observe-state)
    - [Callback adapter](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#callback-adapter)
    - [Combine adapter](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#combine-adapter)
- [Server-Sent Events](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#server-sent-events)
    - [How to initialize](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-initialize-1)
    - [How to connect](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-connect-1)
    - [How to disconnect](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-disconnect-1)
    - [How to terminate](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-terminate-1)
    - [How to receive events](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-receive-events)
    - [How to observe state](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-observe-state-1)
    - [Retry policy](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#retry-policy)
    - [Callback adapter](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#callback-adapter-1)
    - [Combine adapter](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#combine-adapter-1)
- [Advanced Features](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#advanced-features-)
  - [Interceptors](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#interceptors)
    - [Cache Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#cache-interceptor)
    - [Authentication Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#authentication-interceptor)
    - [Redirect Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#redirect-interceptor)
    - [Metrics Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#metrics-interceptor)
    - [Task Lifecycle Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#task-lifecycle-interceptor)
    - [Data Task Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#data-task-interceptor)
    - [Download Task Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#download-task-interceptor)
    - [Upload Task Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#upload-task-interceptor)
    - [Stream Task Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#stream-task-interceptor)
    - [WebSocket Task Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#websocket-task-interceptor)
  - [Session Management](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#session-management)
- [Error Handling](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#error-handling-)


- [Scripts](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#scripts)
- [Contributing](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#contributing-)
- [License](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#license-)

## Installation 📦

### Swift Package Manager

Add EZNetworking to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/Aldo10012/EZNetworking.git", from: "5.2.0")
]
```

Or through Xcode:
1. Go to File > Add Packages
2. Enter: `https://github.com/Aldo10012/EZNetworking.git`
3. Select version: 5.2.0 or later

## Quick Start Guide 🚀

Here's a simple example to get you started:

```swift
// Create a request
let request = RequestFactoryImpl().build(
    httpMethod: .GET,
    urlString: "https://api.example.com/data",
    parameters: [.init(key: "userId", value: "123")]
)

// Using async/await
do {
    let response = try await AsyncRequestPerformer().perform(
        request: request,
        decodeTo: UserData.self
    )
    print("User data: \(response)")
} catch {
    print("Error: \(error)")
}
```

## Advanced Features 🔧

### Interceptors

EZNetworking provides a comprehensive set of interceptors for customizing network behavior:

#### Cache Interceptor

Control caching behavior:

```swift
class CustomCacheInterceptor: CacheInterceptor {
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        willCacheResponse proposedResponse: CachedURLResponse
    ) async -> CachedURLResponse? {
        // Customize caching behavior
        return proposedResponse
    }
}

let delegate = SessionDelegate()
delegate.cacheInterceptor = CustomCacheInterceptor()
```

#### Authentication Interceptor

Handle authentication challenges:

```swift
class CustomAuthInterceptor: AuthenticationInterceptor {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        // Handle authentication
        return (.useCredential, URLCredential(
            user: "username",
            password: "password",
            persistence: .forSession
        ))
    }
}

let delegate = SessionDelegate()
delegate.authenticationInterceptor = CustomAuthInterceptor()
```

#### Redirect Interceptor

Control URL redirections:

```swift
class CustomRedirectInterceptor: RedirectInterceptor {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest
    ) async -> URLRequest? {
        // Handle redirection
        return request
    }
}

let delegate = SessionDelegate()
delegate.redirectInterceptor = CustomRedirectInterceptor()
```

#### Metrics Interceptor

Collect performance metrics:

```swift
class CustomMetricsInterceptor: MetricsInterceptor {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) {
        // Process metrics
        print("Task duration: \(metrics.taskInterval.duration)")
    }
}

let delegate = SessionDelegate()
delegate.metricsInterceptor = CustomMetricsInterceptor()
```

#### Task Lifecycle Interceptor

Monitor task lifecycle events:

```swift
class CustomLifecycleInterceptor: TaskLifecycleInterceptor {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        // Handle task completion
    }
    
    func urlSession(
        _ session: URLSession,
        taskIsWaitingForConnectivity task: URLSessionTask
    ) {
        // Handle connectivity waiting
    }
    
    func urlSession(
        _ session: URLSession,
        didCreateTask task: URLSessionTask
    ) {
        // Handle task creation
    }
}

let delegate = SessionDelegate()
delegate.taskLifecycleInterceptor = CustomLifecycleInterceptor()
```

#### Data Task Interceptor

Process incoming data:

```swift
class CustomDataTaskInterceptor: DataTaskInterceptor {
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        // Process received data
    }
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse
    ) async -> URLSession.ResponseDisposition {
        // Handle response
        return .allow
    }
}

let delegate = SessionDelegate()
delegate.dataTaskInterceptor = CustomDataTaskInterceptor()
```

#### Download Task Interceptor

Monitor download progress:

```swift
class CustomDownloadInterceptor: DownloadTaskInterceptor {
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        // Handle download completion
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        // Track download progress
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        print("Download progress: \(progress)")
    }
}

let delegate = SessionDelegate()
delegate.downloadTaskInterceptor = CustomDownloadInterceptor()
```

#### Upload Task Interceptor

Monitor upload progress

```swift
class CustomUploadTaskInterceptor: UploadTaskInterceptor {
    var progress: (Double) -> Void

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        // Track upload progress
    }
}
```

#### Stream Task Interceptor

Handle streaming operations:

```swift
class CustomStreamInterceptor: StreamTaskInterceptor {
    func urlSession(
        _ session: URLSession,
        streamTask: URLSessionStreamTask,
        didBecome inputStream: InputStream,
        outputStream: OutputStream
    ) {
        // Handle streams
    }
    
    func urlSession(
        _ session: URLSession,
        readClosedFor streamTask: URLSessionStreamTask
    ) {
        // Handle read close
    }
}

let delegate = SessionDelegate()
delegate.streamTaskInterceptor = CustomStreamInterceptor()
```

#### WebSocket Task Interceptor

Handle WebSocket communications:

```swift
class CustomWebSocketInterceptor: WebSocketTaskInterceptor {
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        // Handle WebSocket open
    }
    
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        // Handle WebSocket close
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error
    ) {
        // Handle WebSocket fail to connect
    }

}

let delegate = SessionDelegate()
delegate.webSocketTaskInterceptor = CustomWebSocketInterceptor()
```

### Session Management

Configure and manage URLSession behavior:

```swift
// Create session delegate with interceptors
let delegate = SessionDelegate()
delegate.cacheInterceptor = CustomCacheInterceptor()
delegate.authenticationInterceptor = CustomAuthInterceptor()
delegate.metricsInterceptor = CustomMetricsInterceptor()

// Create performer with custom session delegate. Works for RequestPerformer and AsyncRequestPerformer
let performer = RequestPerformer(sessionDelegate: delegate)

// Use performer for requests
performer.performTask(request: request) { result in
    // Handle result
}
```

## Scripts

`swiftformat Sources Tests`

- Automatically formats the Swift code according to the rules defined in .swiftformat configuration file.

`swiftlint Sources Tests`

- Analyzes the Swift code and reports violations of the rules defined in .swiftlint.yaml configuration file.

`swiftlint --fix Sources Tests`

- Automatically fixes auto-correctable SwiftLint violations in the code.



## Contributing 🤝

Contributions to are always welcomed! For more details see [CONTRIBUTING.md](CONTRIBUTING.md).

## License 📄

EZNetworking is available under the MIT license. See the [LICENSE](https://github.com/Aldo10012/EZNetworking?tab=MIT-1-ov-file) file for more info.
