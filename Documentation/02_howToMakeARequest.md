# Building Requests

EZNetworking provides three ways to create requests:
1. Using RequestFactory for quick, one-line requests
2. Using RequestBuilder for step-by-step request construction
3. Implementing the Request protocol for reusable API endpoints

## Using RequestFactory

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

## Using RequestBuilder

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

## Request Protocol

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
