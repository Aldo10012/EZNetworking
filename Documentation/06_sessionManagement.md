# Session Management

## Session

Configure and manage URLSession behavior:

```swift
// Create session delegate with interceptors
let delegate = SessionDelegate()
delegate.cacheInterceptor = CustomCacheInterceptor()
delegate.authenticationInterceptor = CustomAuthInterceptor()
delegate.metricsInterceptor = CustomMetricsInterceptor()

let session = Session(delegate: delegate)

// Create performer with custom session.
let performer = RequestPerformer(configuration: .default, session: session)

// Use performer for requests
performer.performTask(request: request) { result in
    // Handle result
}
```

## SessionDelegate

EZNetworking uses `SessionDelegate` as the central point for configuring `URLSession` behavior. You assign interceptors to a `SessionDelegate` instance, then pass it to your request performer.

```swift
let delegate = SessionDelegate()
delegate.cacheInterceptor = CustomCacheInterceptor()
delegate.authenticationInterceptor = CustomAuthInterceptor()
delegate.redirectInterceptor = CustomRedirectInterceptor()
delegate.metricsInterceptor = CustomMetricsInterceptor()
delegate.taskLifecycleInterceptor = CustomLifecycleInterceptor()
delegate.dataTaskInterceptor = CustomDataTaskInterceptor()
delegate.downloadTaskInterceptor = CustomDownloadInterceptor()
delegate.streamTaskInterceptor = CustomStreamInterceptor()
delegate.webSocketTaskInterceptor = CustomWebSocketInterceptor()
```

## Interceptors

EZNetworking provides a comprehensive set of interceptors for customizing network behavior:

### Cache Interceptor

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

### Authentication Interceptor

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

### Redirect Interceptor

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

### Metrics Interceptor

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

### Task Lifecycle Interceptor

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

### Data Task Interceptor

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

### Download Task Interceptor

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

### Upload Task Interceptor

Monitor upload progress

```swift
class CustomUploadTaskInterceptor: UploadTaskInterceptor {
    var progress: (Double) -> Void

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        // Track upload progress
    }
}
```

### Stream Task Interceptor

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

### WebSocket Task Interceptor

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
