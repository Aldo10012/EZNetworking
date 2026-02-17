# HTTP Components

## HTTP Methods

Supported HTTP methods:
```swift
public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}
```

## Query Parameters

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

## Headers

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

## Authorization

Multiple authorization methods are supported:

```swift
// Bearer token
.authorization(.bearer("YOUR_TOKEN"))

// Custom auth
.authorization(.custom("Custom-Auth-Value"))

```

## Request Body

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

## Timeout

Configure request timeout interval:

```swift
// With RequestFactory
let request1 = RequestFactoryImpl().build(
    httpMethod: .GET,
    urlString: "https://api.example.com",
    timeoutInterval: 30
)

// With RequestBuilder
let request2 = RequestBuilderImpl()
    .setHttpMethod(.GET)
    .setBaseUrl("https://api.example.com")
    .setTimeoutInterval(30)
    .build()
```

## Cache

Configure request caching behavior:

```swift
// With RequestFactory
let request1 = RequestFactoryImpl().build(
    httpMethod: .GET,
    urlString: "https://api.example.com",
    cachePolicy: .returnCacheDataElseLoad
)

// With RequestBuilder
let request2 = RequestBuilderImpl()
    .setHttpMethod(.GET)
    .setBaseUrl("https://api.example.com")
    .setCachePolicy(.returnCacheDataElseLoad)
    .build()
```
