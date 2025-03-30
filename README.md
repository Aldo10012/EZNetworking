# EZNetworking

EZNetworking is a Swift package designed to simplify network requests and API interaction in your iOS app. It provides easy-to-use abstractions of URLSession, URLRequest, improves performance with built-in caching support, offers full client flexibility/customization, and much more.

## Features
- URLRequest abstraction
- Abstracting API requests
- Swift concurrency support
- HTTP response validation
- Image download
- File download
- Caching
- Request Interceptors/middleware
- 100% Unit Test coverage

## Table of Content
- [Installation](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#installation)
- [Building a Request](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#building-a-request)
    - [Building a Request](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#building-a-request)
        - [Using RequestFactory](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#1-using-requestfactory)
        - [Using RequestBuilderImpl](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#2-using-requestbuilderimpl)
    - [Adding Request Details](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#adding-request-details)
        - [Query Parameters](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#query-parameters)
        - [HTTP Headers](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#http-headers)
        - [Authorization](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#authorization)
        - [Request Body](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#request-body)
        - [Timeout Interval](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#timeout-interval)
        - [Cache Policy](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#cache-policy)
    - [Conforming to the Request Protocol](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#advanced-usage-conforming-to-the-request-protocol)
- [Performing a Request](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#performing-a-request)
    - [How to get an api response using Async/Await?](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-get-an-api-response-using-asyncawait)
    - [How to make api call with Async/Await without decoding a response?](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-make-api-call-using-asyncawait-without-decoding-a-response)
    - [How to get an api response using Completion Handler?](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-get-an-api-response-using-completion-handlers)
    - [How to make api call with Completion Handler without decoding a response?](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-make-api-call-using-completion-handlers-without-decoding-a-response)
    - [How to granularly control your data task](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-granularly-control-your-data-task)
- [Download file](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#download-files)
- [Downlaod Image](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#download-images)
- [Advanced usage](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#advanced-usage)
    - [SessionDelegate](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#sessiondelegate)
    - [CacheInterceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#cacheinterceptor)
    - [AuthenticationInterceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#authenticationinterceptor)
    - [RedirectInterceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#redirectinterceptor)
    - [MetricsInterceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#metricsinterceptor)
    - [TaskLifecycleInterceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#tasklifecycleinterceptor)
    - [DataTaskinterceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#datataskinterceptor)
    - [DownloadTaskInterceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#downloadtaskinterceptor)
    - [StreamTaskInterceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#streamtaskinterceptor)
    - [WebsocketInterceptor](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#websockettaskinterceptor)
 

## Installation

### Swift Package Manager

To integrate EZnetworking into your Xcode project using Swift Package Manager, add the following dependency to your Package.swift file:

swift
```
dependencies: [
    .package(url: "https://github.com/Aldo10012/EZNetworking.git", from: "2.1.0")
]
```
Alternatively, you can add the package directly through Xcode:

Open your project in Xcode.
Go to File > Add Packages....
Enter the package repository URL: https://github.com/Aldo10012/EZNetworking.git.
Choose the version and add the package to your project.


## Usage

### Building a Request
The library provides two convenient ways to create URLRequest objects: RequestFactory for quick one-step request creation and RequestBuilderImpl for a more flexible, step-by-step approach.

#### 1. Using RequestFactory
RequestFactory is perfect for quickly creating a URLRequest in a single function call.

Example:

```swift
let request = RequestFactoryImpl().build(
    httpMethod: .GET,
    urlString: "http://www.example.com",
    parameters: [
        .init(key: "key_1", value: "value_1"),
        .init(key: "key_2", value: "value_2")
    ],
    header: [
        .accept(.json),
        .contentType(.json),
        .authorization(.bearer("YOUR_API_KEY"))
    ],
    body: .data(Data()),
    timeInterval: 30
)
```

Parameters:

- `httpMethod`: Specify the `HTTPMethod` (GET, POST, PUT, DELETE).
- `urlString`: Provide the base URL as a string.
- `parameters`: Pass query parameters as an array of `HTTPParameter` (optional).
- `headers`: Include HTTP headers as an array of `HTTPHeader` (optional).
- `body`: Add a `Data` object for the request body (optional).
- `timeoutInterval`: Set the timeout interval for the request (optional).

#### 2. Using RequestBuilderImpl
For more flexibility, use RequestBuilderImpl to construct a URLRequest step-by-step. This approach allows you to dynamically set request properties as needed.

Example:

```swift
let request = RequestBuilderImpl()
    .setHttpMethod(.POST)
    .setBaseUrl("http://www.example.com")
    .setParameters([
        .init(key: "key_1", value: "value_1"),
        .init(key: "key_2", value: "value_2")
    ])
    .setHeaders([
        .accept(.json),
        .contentType(.json),
        .authorization(.bearer("YOUR_API_KEY"))
    ])
    .setBody(.data(Data()))
    .setTimeoutInterval(30)
    .build()
```
Builder Methods:

- `setHttpMethod(_:)`: Set the `HTTPMethod` method (GET, POST, etc.).
- `setBaseUrl(_:)`: Define the base URL as a string.
- `setParameters(_:)`: Add query parameters as an array of `HTTPParameter`.
- `setHeaders(_:)`: Specify HTTP headers as an array of `HTTPHeader`.
- `setBody(_:)`: Include the request body as a `Data` object.
- `setTimeoutInterval(_:)`: Set the timeout interval for the request.

### Adding Request Details

#### Query Parameters

Add query parameters as an array of HTTPParameter.

Example:

```swift
let parameters: [HTTPParameter] = [
    HTTPParameter(key: "key_1", value: "value_1"),
    HTTPParameter(key: "key_2", value: "value_2")
]
```

With `RequestFactory`:

```swift
let request = RequestFactoryImpl().build(
    httpMethod: .GET,
    urlString: "http://www.example.com",
    parameters: parameters
)
```

With `RequestBuilderImpl`:

```swift
let request = RequestBuilderImpl()
    .setHttpMethod(.GET)
    .setBaseUrl("http://www.example.com")
    .setParameters(parameters)
    .build()
```

#### HTTP Headers

Include headers with predefined cases in the HTTPHeader enum. Common headers include:

`.accept(.json)`
`.contentType(.json)`
`.authorization(.bearer(""))`

Example:

```swift
let headers: [HTTPHeader] = [
    .accept(.json),
    .contentType(.json),
    .authorization(.bearer("YOUR_API_KEY"))
]
```

With `RequestFactory`:

```swift
let request = RequestFactoryImpl().build(
    httpMethod: .GET,
    urlString: "http://www.example.com",
    headers: headers
)
```

With `RequestBuilderImpl`:

```swift
let request = RequestBuilderImpl()
    .setHttpMethod(.GET)
    .setBaseUrl("http://www.example.com")
    .setHeaders(headers)
    .build()
```

#### Authorization

The `HTTPHeader.authorization` enum handles common authorization needs:

Bearer Token: `.authorization(.bearer("YOUR_TOKEN"))`

Custom Authorization: `.authorization(.custom("CUSTOM_AUTH_VALUE"))`

#### Request Body

Include a request body by passing a Data object to the body parameter.

Example:

```swift
let bodyData = HTTPBody.jsonString("{\"name\":\"John\"}")
```

With `RequestFactory`:

```swift
let request = RequestFactoryImpl().build(
    httpMethod: .POST,
    urlString: "http://www.example.com",
    body: bodyData
)
```

With `RequestBuilderImpl`:

```swift
let request = RequestBuilderImpl()
    .setHttpMethod(.POST)
    .setBaseUrl("http://www.example.com")
    .setBody(bodyData)
    .build()
```

#### Timeout Interval

Set a timeout interval in seconds using the timeoutInterval parameter.

With `RequestFactory`:

```swift
let request = RequestFactoryImpl().build(
    httpMethod: .GET,
    urlString: "http://www.example.com",
    timeoutInterval: 30
)
```

With `RequestBuilderImpl`:

```swift
let request = RequestBuilderImpl()
    .setHttpMethod(.GET)
    .setBaseUrl("http://www.example.com")
    .setTimeoutInterval(30)
    .build()
```

#### Cache Policy

Set a cache policy for your request to use using the cachePolicy parameter.

ith `RequestFactory`:

```swift
let request = RequestFactoryImpl().build(
    httpMethod: .GET,
    urlString: "http://www.example.com",
    cachePolicy: .useProtocolCachePolicy
)
```

With `RequestBuilderImpl`:

```swift
let request = RequestBuilderImpl()
    .setHttpMethod(.GET)
    .setBaseUrl("http://www.example.com")
    .setCachePolicy(.useProtocolCachePolicy)
    .build()
```


### Conforming to the Request Protocol
Encapsulate request data in a reusable struct or class conforming to the Request protocol. This approach allows you to manage API requests in one place and inject them where needed.

Example:

```swift
struct MyRequest: Request {
    var httpMethod: HTTPMethod { .GET }
    var baseUrlString: String { "http://www.example.com" }
    var parameters: [HTTPParameter]? {[
        .init(key: "key_1", value: "value_1"),
        .init(key: "key_2", value: "value_2")
    ]}
    var headers: [HTTPHeader]? {[
        .accept(.json),
        .contentType(.json),
        .authorization(.bearer("YOUR_API_KEY"))
    ]}
    var body: Data? { HTTPBody.jsonString("{\"name\":\"John\"}") }
    var timeoutInterval: TimeInterval { 30 }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
}
```

### Performing a Request

You can easily execute Requests using `AsyncRequestPerformer()` or `RequestPerformer()` It can manage error handling and is capable of performing requests and returning responses using Async/Await and Completion Handlers.

- If you opt to perform your network requests using `Async/Await`, try using `AsyncRequestPerformer()`
- If you opt to perform your network requests using callbacks, try using `RequestPerformer()`
- each of the below methods contains a `request` argument, which accepts either a `URLRequest` (_which you can use the `RequestBuilder` to construct)_ or a `Request` object

#### How to get an api response using `Async/Await`?

Create a request using either RequestBuilder or Request and inject it into 
```swift
func asyncMethodName() async throws {
    do {
        // Option A: using RequestFactory
        let request = RequestFactoryImpl().build(httpMethod: .GET, urlString: "http://www.example.com", parameters: [])!  
        let personA = try await AsyncRequestPerformer().perform(request: request, decodeTo: Person.self)
        print(personA.age, personA.name)

        // Option B: using Request protocol
        let personB = try await AsyncRequestPerformer().perform(request: GetPersonRequest(), decodeTo: Person.self) // GetPersonRequest conforms to Request
        print(personB.age, personB.name)
    } catch let error as NetworkingError {
        print(error)
    }
}
```

#### How to make api call using `Async/Await` without decoding a response?
```swift
func asyncMethodName() async throws {
    do {
        // Option A: using RequestFactory
        let request = RequestFactoryImpl().build(httpMethod: .GET, urlString: "http://www.example.com", parameters: [])!    
        try await AsyncRequestPerformer().perform(request: request)
        print("Did succeed")

        // Option B: using Request protocol
        try await AsyncRequestPerformer().perform(request: GetPersonRequest()) // GetPersonRequest conforms to Request
        print("Did succeed")
    } catch let error as NetworkingError {
        print(error)
    }
}
```

#### How to get an api response using completion handlers?
```swift
// Option A: Using RequestFactory
let request = RequestFactoryImpl().build(httpMethod: .GET, urlString: "http://www.example.com", parameters: [])
RequestPerformer().performTask(request: request, decodeTo: Person.self) { result in
    switch result {
    case .success(let person):
        print(person.name, person.age)
    case .failure(let error):
        print(error)
    }
}

// Option B: Using Request protocol
RequestPerformer().performTask(request: GetPersonRequest(), decodeTo: Person.self) { result in // GetPersonRequest conforms to Request
    switch result {
    case .success(let person):
        print(person.name, person.age)
    case .failure(let error):
        print(error)
    }
}
```

#### How to make api call using completion handlers without decoding a response?
```swift
// Option A: Using RequestFactory
let request = RequestFactoryImpl().build(httpMethod: .GET, urlString: "http://www.example.com", parameters: [])
RequestPerformer().performTask(request: request) { result in
    switch result {
    case .success:
        print("did succeed")
    case .failure(let error):
        print(error)
    }
}

// Option B: Using Request protocol
RequestPerformer().performTask(request: GetPersonRequest()) { result in // GetPersonRequest conforms to Request
    switch result {
    case .success:
        print("did succeed")
    case .failure(let error):
        print(error)
    }
}
```

#### How to granularly control your data task?

`RequestPerformer().performTask()` returns an instance of `URLSessionDataTask`. It is marked as `@discardableResult` so XCode will not throw any errors if you do not store returned value. Inernally, before returning the data task instance, the `.resume()` method is called you if you only want to call a simple request and don't care about granular control, you don't need to, but if you would like the extra control, you can store the resulting task in a variable and you can call it's methods.

Example
```swift
let task = RequestPerformer().performTask(request: GetPersonRequest()) { _ in
   ...
}

// something happens and you want to cancel the task
task.cancel()
```

### Download Files

You can easily download files with `async/await` using or with completion handlers using `FileDownloader()`

#### Async/Await
```swift
let testURL = URL(string: "https://example.com/example.pdf")!
do {
    let localURL = try await FileDownloader().downloadFile(with: testURL)
    // handle the returned local URL path. Perhaps write and save it in FileManager
} catch let error as NetworkingError{
    // handle error
}
```

#### Completion hander
```swift
let testURL = URL(string: "https://example.com/example.pdf")!
FileDownloader().downloadFile(url: testURL) { result in
    switch result {
    case .success:
        // handle the returned local URL path. Perhaps write and save it in FileManager
    case .failure(let error):
        // handle error
    }
}
```

Similar to `RequestPerformer.performTask()`, `FileDownloader.downloadFile()` returns a `@discardableResult` instance of `URLSessionDownloadTask` that calls `.resume()` just before returning so you as a client don't need to, but if you would like the extra control, you can store the result in a variable and have access to it's several methods such as cancel()

```swift
let task = FileDownloader().downloadFile(url: testURL) { _ in
    ...
}
// something happens and you want to cancel the download task
task.cancel()
```

### Download Images

You can easily download images with `async/await` or with completion handlers using `ImageDownloader()`

#### Async/Await
```swift
let imageURL = URL(string: "https://some_image_url.png")
do {
    let image = try await ImageDownloader().downloadImage(from: imageURL)
    // handle success
} catch let error as NetworkingError {
    // handle error
}
```

#### Completion hander
```swift
let imageURL = URL(string: "https://some_image_url.png")
ImageDownloader().downloadImageTask(url: imageURL) { result in
    switch result {
    case .success:
        // handle success
    case .failure(let error):
        // handle error
    }
}
```

Similar to `RequestPerformer.performTask()`, `ImageDownloader.downloadImageTask()` returns a `@discardableResult` instance of `URLSessionDataTask` that calls `.resume()` just before returning so you as a client don't need to, but if you would like the extra control, you can store the result in a variable and have access to it's several methods such as cancel()

```swift
let task = ImageDownloader().downloadImageTask(url: testURL) { _ in
    ...
}
// something happens and you want to cancel the download task
task.cancel()
```

### Advanced usage
EZNetworking provides more advanced usages than just making a request and decoding a response. Clients can also intercept requests through interceptors that act as middleware. 

#### SessionDelegate
`SessionDelegate` is the entrypoint to allow you to add much more customization to your network calls. To add a `SessionDelegate`, create an instance and pass it into your performer.
```swift
let delegate = SessionDelegate()
let performer = RequestPerformer(sessionDelegate: delegate)
```
By default, SessionDelegate by itself doesn't do anything and still allows network requests to act as per normal. If you want to add deeper functionality, you would need to integrate one (or more) of many interceptors available.

#### CacheInterceptor
CacheInterceptor is a Protocol for intercepting URL cache operations. 
You can create your own object conforming to CacheInterceptor to meet your specific business needs.
Example:
```swift
class MyCustomCacheInterceptor: CacheInterceptor {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse) async -> CachedURLResponse? {
        // your implementation
    }
}
let delegate = SessionDelegate()
delegate.cacheInterceptor = MyCustomCacheInterceptor()
let performer = RequestPerformer(sessionDelegate: delegate)
```

#### AuthenticationInterceptor
AuthenticationInterceptor is a Protocol for intercepting and handling URL authentication challenges. 
You can create your own object conforming to AuthenticationInterceptor to handle authentication for your requests.
Example:
```swift
class MyCustomAuthInterceptor: AuthenticationInterceptor {
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        // your implementation
        return (.useCredential, URLCredential(user: "username", password: "password", persistence: .forSession))
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        // your implementation
        return (.performDefaultHandling, nil)
    }
}

let delegate = SessionDelegate()
delegate.authenticationInterceptor = MyCustomAuthInterceptor()
let performer = RequestPerformer(sessionDelegate: delegate)
```

#### RedirectInterceptor
RedirectInterceptor is a Protocol for intercepting URL redirect operations.
You can create your own object conforming to RedirectInterceptor to control how redirects are handled.
Example:
```swift
class MyCustomRedirectInterceptor: RedirectInterceptor {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        // your implementation
        return request
    }
}

let delegate = SessionDelegate()
delegate.redirectInterceptor = MyCustomRedirectInterceptor()
let performer = RequestPerformer(sessionDelegate: delegate)
```

#### MetricsInterceptor
MetricsInterceptor is a Protocol for intercepting URL metrics collection.
You can create your own object conforming to MetricsInterceptor to collect performance metrics for your network requests.
Example:
```swift
class MyCustomMetricsInterceptor: MetricsInterceptor {
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        // your implementation
    }
}

let delegate = SessionDelegate()
delegate.metricsInterceptor = MyCustomMetricsInterceptor()
let performer = RequestPerformer(sessionDelegate: delegate)
```

#### TaskLifecycleInterceptor
TaskLifecycleInterceptor is a Protocol for intercepting task lifecycle events.
You can create your own object conforming to TaskLifecycleInterceptor to monitor and respond to the different stages of a network task's lifecycle.
Example:
```swift
class MyCustomLifecycleInterceptor: TaskLifecycleInterceptor {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // your implementation
    }
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        // your implementation
    }
    
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        // your implementation
    }
}

let delegate = SessionDelegate()
delegate.taskLifecycleInterceptor = MyCustomLifecycleInterceptor()
let performer = RequestPerformer(sessionDelegate: delegate)
```

#### DataTaskInterceptor
DataTaskInterceptor is a Protocol for intercepting data tasks specifically.
You can create your own object conforming to DataTaskInterceptor to process incoming data during a request.
Example:
```swift
class MyCustomDataTaskInterceptor: DataTaskInterceptor {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // your implementation
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        // your implementation
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        // your implementation
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
        // your implementation
        return .allow
    }
}

let delegate = SessionDelegate()
delegate.dataTaskInterceptor = MyCustomDataTaskInterceptor()
let performer = RequestPerformer(sessionDelegate: delegate)
```

#### DownloadTaskInterceptor
DownloadTaskInterceptor is a Protocol for intercepting download tasks specifically.
You can create your own object conforming to DownloadTaskInterceptor to monitor and process file downloads.
Example:
```swift
class MyCustomDownloadInterceptor: DownloadTaskInterceptor {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // your implementation
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // your implementation
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        // your implementation
    }
}

let delegate = SessionDelegate()
delegate.downloadTaskInterceptor = MyCustomDownloadInterceptor()
let performer = RequestPerformer(sessionDelegate: delegate)
```

#### StreamTaskInterceptor
StreamTaskInterceptor is a Protocol for intercepting stream tasks specifically.
You can create your own object conforming to StreamTaskInterceptor to handle network streaming operations.
Example:
```swift
class MyCustomStreamInterceptor: StreamTaskInterceptor {
    func urlSession(_ session: URLSession, readClosedFor streamTask: URLSessionStreamTask) {
        // your implementation
    }
    
    func urlSession(_ session: URLSession, writeClosedFor streamTask: URLSessionStreamTask) {
        // your implementation
    }
    
    func urlSession(_ session: URLSession, betterRouteDiscoveredFor streamTask: URLSessionStreamTask) {
        // your implementation
    }
    
    func urlSession(_ session: URLSession, streamTask: URLSessionStreamTask, didBecome inputStream: InputStream, outputStream: OutputStream) {
        // your implementation
    }
}

let delegate = SessionDelegate()
delegate.streamTaskInterceptor = MyCustomStreamInterceptor()
let performer = RequestPerformer(sessionDelegate: delegate)
```

#### WebSocketTaskInterceptor
WebSocketTaskInterceptor is a Protocol for intercepting WebSocket tasks specifically.
You can create your own object conforming to WebSocketTaskInterceptor to monitor and respond to WebSocket events.
Example:
```swift
class MyCustomWebSocketInterceptor: WebSocketTaskInterceptor {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        // your implementation
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        // your implementation
    }
}

let delegate = SessionDelegate()
delegate.webSocketTaskInterceptor = MyCustomWebSocketInterceptor()
let performer = RequestPerformer(sessionDelegate: delegate)
```



