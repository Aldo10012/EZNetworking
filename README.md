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
- **File & Image Downloads**: Easy-to-use download utilities
- **Extensive Testing**: 100% unit test coverage

## Table of Contents 📑

- [Installation](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#installation-)
- [Quick Start Guide](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#quick-start-guide-)
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
- [Download Features](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#download-features-)
  - [File Downloads](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#file-downloads)
  - [Image Downloads](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#image-downloads)
- [Advanced Features](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#advanced-features-)
  - [Interceptors](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#interceptors)
    - [Cache Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#cache-interceptor)
    - [Authentication Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#authentication-interceptor)
    - [Redirect Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#redirect-interceptor)
    - [Metrics Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#metrics-interceptor)
    - [Task Lifecycle Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#task-lifecycle-interceptor)
    - [Data Task Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#data-task-interceptor)
    - [Download Task Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#download-task-interceptor)
    - [Stream Task Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#stream-task-interceptor)
    - [WebSocket Task Interceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#websocket-task-interceptor)
  - [Session Management](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#session-management)
- [Error Handling](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#error-handling-)
- [Contributing](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#contributing-)
- [License](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#license-)

## Installation 📦

### Swift Package Manager

Add EZNetworking to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/Aldo10012/EZNetworking.git", from: "3.1.0")
]
```

Or through Xcode:
1. Go to File > Add Packages
2. Enter: `https://github.com/Aldo10012/EZNetworking.git`
3. Select version: 3.1.0 or later

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

## Building Requests 🏗️

EZNetworking provides three ways to create requests:
1. Using RequestFactory for quick, one-line requests
2. Using RequestBuilder for step-by-step request construction
3. Implementing the Request protocol for reusable API endpoints

### Using RequestFactory

Perfect for quick, one-line request creation:

```swift
let request = RequestFactoryImpl().build(
    httpMethod: .POST,
    urlString: "https://api.example.com/users",
    parameters: [
        .init(key: "name", value: "John Doe"),
        .init(key: "email", value: "john@example.com")
    ],
    headers: [
        .accept(.json),
        .contentType(.json)
    ],
    body: .jsonString("{\"role\":\"user\"}"),
    timeoutInterval: 30,
    cachePolicy: .useProtocolCachePolicy
)
```

### Using RequestBuilder

Ideal for complex requests with multiple configurations:

```swift
let request = RequestBuilderImpl()
    .setHttpMethod(.POST)
    .setBaseUrl("https://api.example.com")
    .setParameters([
        .init(key: "api_version", value: "v2")
    ])
    .setHeaders([
        .accept(.json),
        .authorization(.bearer("YOUR_TOKEN"))
    ])
    .setBody(.jsonString("{\"data\":\"value\"}"))
    .setTimeoutInterval(30)
    .setCachePolicy(.useProtocolCachePolicy)
    .build()
```

### Request Protocol

The Request protocol allows you to create reusable request definitions:

```swift
struct UserRequest: Request {
    let userId: String
    
    var httpMethod: HTTPMethod { .GET }
    var baseUrlString: String { "https://api.example.com" }
    var parameters: [HTTPParameter]? {[
        .init(key: "user_id", value: userId),
        .init(key: "version", value: "v2")
    ]}
    var headers: [HTTPHeader]? {[
        .accept(.json),
        .contentType(.json),
        .authorization(.bearer("YOUR_TOKEN"))
    ]}
    var body: HTTPBody? { nil }
    var timeoutInterval: TimeInterval { 30 }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
}

// Usage
let userRequest = UserRequest(userId: "123")
let response = try await AsyncRequestPerformer().perform(
    request: userRequest,
    decodeTo: UserData.self
)
```

## Request Components 🔧

### HTTP Methods

Supported HTTP methods:
```swift
public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}
```

### Query Parameters

Add query parameters to your requests:

```swift
let parameters: [HTTPParameter] = [
    .init(key: "page", value: "1"),
    .init(key: "limit", value: "20"),
    .init(key: "sort", value: "desc")
]

// With RequestFactory
let request1 = RequestFactoryImpl().build(
    httpMethod: .GET,
    urlString: "https://api.example.com",
    parameters: parameters
)

// With RequestBuilder
let request2 = RequestBuilderImpl()
    .setHttpMethod(.GET)
    .setBaseUrl("https://api.example.com")
    .setParameters(parameters)
    .build()
```

### Headers

EZNetworking provides a type-safe way to add headers:

```swift
let headers: [HTTPHeader] = [
    .accept(.json),
    .contentType(.json),
    .authorization(.bearer("YOUR_TOKEN")),
    .custom(key: "X-Custom-Header", value: "custom-value")
]

// Common header types
public enum HTTPHeader {
    case accept(ContentType)
    case contentType(ContentType)
    case authorization(AuthorizationType)
    case custom(key: String, value: String)
    // ... other http header types
}

public enum ContentType: String {
    case json = "application/json"
    case xml = "application/xml"
    case formUrlEncoded = "application/x-www-form-urlencoded"
    case multipartFormData = "multipart/form-data"
    // ... other content types
}
```

### Authorization

Multiple authorization methods are supported:

```swift
// Bearer token
.authorization(.bearer("YOUR_TOKEN"))

// Custom auth
.authorization(.custom("Custom-Auth-Value"))

```

### Request Body

Multiple body types are supported:

```swift
// JSON String
let jsonBody = HTTPBody.jsonString("{\"key\":\"value\"}")

// Data
let dataBody = HTTPBody.data(someData)

// Form URL Encoded
let formBody = HTTPBody.formUrlEncoded([
    "key1": "value1",
    "key2": "value2"
])

// Multipart Form Data
let multipartBody = HTTPBody.multipartFormData([
    .init(name: "file", fileName: "image.jpg", data: imageData),
    .init(name: "description", value: "Profile picture")
])
```

### Timeout and Cache

Configure request timeout and caching behavior:

```swift
// With RequestFactory
let request1 = RequestFactoryImpl().build(
    httpMethod: .GET,
    urlString: "https://api.example.com",
    timeoutInterval: 30,
    cachePolicy: .returnCacheDataElseLoad
)

// With RequestBuilder
let request2 = RequestBuilderImpl()
    .setHttpMethod(.GET)
    .setBaseUrl("https://api.example.com")
    .setTimeoutInterval(30)
    .setCachePolicy(.returnCacheDataElseLoad)
    .build()
```

## Making Network Calls 🌐

### Async/Await Usage

Modern Swift concurrency support:

```swift
// With response decoding
do {
    let userData = try await RequestPerformer().perform(request: request, decodeTo: UserData.self)
    // Handle decoded response
} catch {
    // Handle error
}

// Without decoding
do {
    try await RequestPerformer().perform(request: request, decodeTo: EmptyResponse.self)
    // Handle success
} catch {
    // Handle error
}
```

### Completion Handlers

Traditional callback-based approach:

```swift
// With response decoding
RequestPerformer().performTask(request: request, decodeTo: UserData.self) { result in
    switch result {
    case .success(let userData):
        // Handle decoded response
    case .failure(let error):
        // Handle error
    }
}

// Without decoding
RequestPerformer().performTask(request: request, decodeTo: EmptyResponse.self) { result in
    switch result {
    case .success:
        // Handle success
    case .failure(let error):
        // Handle error
    }
}
```

### Task Control

Control over URLSessionTask:

```swift
// Store task reference
let task = RequestPerformer().performTask(request: request) { _ in
    // Handle completion
}

// Cancel task if needed
task.cancel()

// Resume suspended task
task.resume()

// Suspend task
task.suspend()

// Get task state
print(task.state) // running, suspended, canceling, completed
```

## Download Features 📥

### File Downloads

```swift
let fileURL = URL(string: "https://example.com/file.pdf")!

// Async/await
do {
    let localURL = try await FileDownloader().downloadFile(with: fileURL)
    // Handle downloaded file
} catch {
    // Handle error
}

// Completion handler with progress tracking
let task = FileDownloader().downloadFile(url: testURL) { result in
    switch result {
    case .success:
        // handle the returned local URL path. Perhaps write and save it in FileManager
    case .failure(let error):
        // handle error
    }
}

// Cancel download if needed
task.cancel()
```

### Image Downloads

```swift
let imageURL = URL(string: "https://example.com/image.jpg")!

// Async/await
do {
    let image = try await ImageDownloader().downloadImage(from: imageURL)
    // Use downloaded image
} catch {
    // Handle error
}

// Completion handler with caching
let task = ImageDownloader().downloadImageTask(url: imageURL) { result in
    switch result {
    case .success:
        // handle success
    case .failure(let error):
        // handle error
    }
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

## Error Handling 🚨

EZNetworking provides comprehensive error handling:

```swift
public enum NetworkingError: Error {
    // Internal errors
    case internalError(InternalError)                                   /// any internal error

    // HTTP Status Code errors
    case information(HTTPInformationalStatus, URLResponseHeaders)       /// 1xx status code errors
    case redirect(HTTPRedirectionStatus, URLResponseHeaders)            /// 3xx status code errors
    case httpClientError(HTTPClientErrorStatus, URLResponseHeaders)     /// 4xx status code errors
    case httpServerError(HTTPServerErrorStatus, URLResponseHeaders)     /// 5xx status code errors

    // URL Errors
    case urlError(URLError)                                             /// any URL error
}

// Error handling example
do {
    let response = try await AsyncRequestPerformer().perform(request: request, decodeTo: UserData.self)
    // do something with response
} catch let error as NetworkingError {
    switch error {
    case .internalError(let internalError):
        // some internal error such as failed to decode or url not valid
    case .information(let hTTPInformationalStatus, let uRLResponseHeaders):
        // .. some 1xx status code error
    case .redirect(let hTTPRedirectionStatus, let uRLResponseHeaders):
        // some 3xx status code error
    case .httpClientError(let hTTPClientErrorStatus, let uRLResponseHeaders):
        // some 4xx status code error
    case .httpServerError(let hTTPServerErrorStatus, let uRLResponseHeaders):
        // some 5xx status code error
    case .urlError(let uRLError):
        // some error of type URLError
    }
}
```

## Contributing 🤝

Contributions are welcome! If you have an idea to improve EZNetworking, please feel free to submit and open a pull request or open an issue.

## License 📄

EZNetworking is available under the MIT license. See the [LICENSE](https://github.com/Aldo10012/EZNetworking?tab=MIT-1-ov-file) file for more info.
