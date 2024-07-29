# EZNetworking

EZNetworking is a Swift package that provides a set of awesome utilities to make Swift networking development easier and more fun.

## Table of Content
- [Installation](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#installation)
- [Building a Request](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#building-a-request)
    - [How to add query params?](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-add-query-parameters)
    - [How to add headers?](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-add-headers)
    - [What about Authorization?](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#what-about-authorization)
    - [How to add a body?](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-add-a-body)
    - [How to add a time interval?](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-do-i-add-a-time-interval)
- [Performing a Request](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#performing-a-request)
    - [How to get an api response using Async/Await?](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-get-an-api-response-using-asyncawait)
    - [How to make api call with Async/Await without decoding a response?](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-make-api-call-using-asyncawait-without-decoding-a-response)
    - [How to get an api response using Completion Handler?](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-get-an-api-response-using-completion-handlers)
    - [How to make api call with Completion Handler without decoding a response?](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#how-to-make-api-call-using-completion-handlers-without-decoding-a-response)
- [Download file](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#download-files)
- [Downlaod Image](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#download-images)
 

## Installation

### Swift Package Manager

To integrate EZnetworking into your Xcode project using Swift Package Manager, add the following dependency to your Package.swift file:

swift
Copy code
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

To quickly and easily create a URLRequest utilize the RequestBuilder()

```swift
let request = RequestBuilder().build(httpMethod: .GET, urlString: "http://www.example.com", parameters: [])
```
- `httpMethod`: inject the http method you want to use: `GET`, `POST`, `PUT`, `DELETE`
- `urlString`: inject your api url as a string
- `parameters`: inject a list of query parameters

#### How to add query parameters?
Just pass in an array of `HTTPParameter` into the `parameters` argument. Here's an example.
```swift
let request = RequestBuilder().build(
        httpMethod: .GET,
        urlString: "http://www.example.com",
        parameters: [
            .init(key: "query_param_key_1", value: "query_param_value_1"),
            .init(key: "query_param_key_2", value: "query_param_value_2"),
            .init(key: "query_param_key_3", value: "query_param_value_3")
        ]
    )
```

#### How to add headers?

The next argument in you can pass in an array of `HTTPHeader`. `HTTPHeader` is an enum where each case is associated with a different http header. Some common ones are `.accept(MediaType)` and `.contentType(MediaType)`.

Here's an example.
```swift
let request = RequestBuilder().build(
        httpMethod: .GET,
        urlString: "http://www.example.com",
        parameters: [
            .init(key: "query_param_key_1", value: "query_param_value_1"),
            .init(key: "query_param_key_2", value: "query_param_value_2"),
            .init(key: "query_param_key_3", value: "query_param_value_3")
        ],
        headers: [
            .accept(.json),
            .contentType(.json)
        ]
    )
```

#### What about authorization?

Many API calls require the "Authorization" field. This is handled by `HTTPHeader.authorization(Authorization)`. 
The most common method of authorization is Bearer. ex: `"Authorization": "Bearer YOUR_API_KEY"` You can easily do this with the `Authorization.bearer(String)`
Here's an example

```swift
let request = RequestBuilder().build(
        httpMethod: .GET,
        urlString: "http://www.example.com",
        parameters: [
            .init(key: "query_param_key_1", value: "query_param_value_1"),
            .init(key: "query_param_key_2", value: "query_param_value_2"),
            .init(key: "query_param_key_3", value: "query_param_value_3")
        ],
        headers: [
            .accept(.json),
            .contentType(.json),
            .authorization(.bearer("Your_API_KEY"))
        ]
    )
```


##### How do I set custom headers if not handled by `HTTPHeader`?

If you are not using "Bearer" for authorizaiton, you can use `Authorization.custom(String)`. Here's an example:
```swift
let request = RequestBuilder().build(
        httpMethod: .GET,
        urlString: "http://www.example.com",
        parameters: [
            .init(key: "query_param_key_1", value: "query_param_value_1"),
            .init(key: "query_param_key_2", value: "query_param_value_2"),
            .init(key: "query_param_key_3", value: "query_param_value_3")
        ],
        headers: [
            .accept(.json),
            .contentType(.json),
            .authorization(.custom("custom_non_bearer_value"))
        ]
    )
```

#### How to add a body?

Inject a `Data` object into the `body` parameter. 

```swift
let myData: Data()
let request = RequestBuilder().build(
        httpMethod: .GET,
        urlString: "http://www.example.com",
        parameters: [
            .init(key: "query_param_key_1", value: "query_param_value_1"),
            .init(key: "query_param_key_2", value: "query_param_value_2"),
            .init(key: "query_param_key_3", value: "query_param_value_3")
        ],
        headers: [
            .accept(.json),
            .contentType(.json),
            .authorization(.bearer("Your_API_KEY"))
        ],
        body: myData
    )
```

#### How do I add a time interval?

Assign a value to `timeoutInterval`
```swift
let myData: Data()
let request = RequestBuilder().build(
        httpMethod: .GET,
        urlString: "http://www.example.com",
        parameters: [
            .init(key: "query_param_key_1", value: "query_param_value_1"),
            .init(key: "query_param_key_2", value: "query_param_value_2"),
            .init(key: "query_param_key_3", value: "query_param_value_3")
        ],
        headers: [
            .accept(.json),
            .contentType(.json),
            .authorization(.bearer("Your_API_KEY"))
        ],
        body: myData,
        timeoutInterval: 30
    )
```

### Performing a Request

You can easily execute Requests using `AsyncRequestPerformer()` or `RequestPerformer()` It can manage error handling and is capable of performing requests and returning responses using Async/Await and Completion Handlers.

- If you opt to performing your network requests using `Async/Await`, try using `AsyncRequestPerformer()`
- If you opt to performing your network requests using callbacks, try using `RequestPerformer()`

#### How to get an api response using `Async/Await`?
```swift
func asyncMethodName() async throws {
    let request = RequestBuilder().build(httpMethod: .GET, urlString: "http://www.example.com", parameters: [])!
    let performer = AsyncRequestPerformer()
    
    do {
        let person = try await performer.perform(request: request, decodeTo: Person.self)
        print(person.age, person.name)
    } catch let error as NetworkingError {
        print(error)
    }
}
```

#### How to make api call using `Async/Await` without decoding a response?
```swift
func asyncMethodName() async throws {
    let request = RequestBuilder().build(httpMethod: .GET, urlString: "http://www.example.com", parameters: [])!
    let performer = AsyncRequestPerformer()
    
    do {
        try await performer.perform(request: request)
        print("Did succeed")
    } catch let error as NetworkingError {
        print(error)
    }
}
```

#### How to get an api response using completion handlers?
```swift
let request = RequestBuilder().build(httpMethod: .GET, urlString: "http://www.example.com", parameters: [])
let performer = RequestPerformer()
let task = performer.performTask(request: request, decodeTo: Person.self) { result in
    switch result {
    case .success(let person):
        print(person.name, person.age)
    case .failure(let error):
        print(error)
    }
}
task.resume()
```

#### How to make api call using completion handlers without decoding a response?
```swift
let request = RequestBuilder().build(httpMethod: .GET, urlString: "http://www.example.com", parameters: [])
let performer = RequestPerformer()
let task = performer.performTask(request: request) { result in
    switch result {
    case .success:
        print("did succeed")
    case .failure(let error):
        print(error)
    }
}
task.reaume()
```

### Download Files

You can easily download files with `async/await` using `AsyncRequestPerformer()` or with completion handlers using `RequestPerformer()`

#### Async/Await
```swift
let testURL = URL(string: "https://example.com/example.pdf")!
do {
    let localURL = try await AsyncRequestPerformer().downloadFile(with: testURL)
    // handle the returned local URL path. Perhaps write and save it in FileManager
} catch let error as NetworkingError{
    // handle error
}
```

#### Completion hander
```swift
let testURL = URL(string: "https://example.com/example.pdf")!
let task = RequestPerformer().downloadFile(url: testURL) { result in
    switch result {
    case .success:
        // handle the returned local URL path. Perhaps write and save it in FileManager
    case .failure(let error):
        // handle error
    }
}
task.resume()
```

### Download Images

You can easily download images with `async/await` using `AsyncRequestPerformer()` or with completion handlers using `RequestPerformer()`

#### Async/Await
```swift
let imageURL = URL(string: "https://some_image_url.png")
do {
    let image = try await AsyncRequestPerformer().downloadImage(from: imageURL)
    // handle success
} catch let error as NetworkingError {
    // handle error
}
```

#### Completion hander
```swift
let imageURL = URL(string: "https://some_image_url.png")
let task = RequestPerformer().downloadImageTask(url: imageURL) { result in
    switch result {
    case .success:
        // handle success
    case .failure(let error):
        // handle error
    }
}
task.resume()
```
