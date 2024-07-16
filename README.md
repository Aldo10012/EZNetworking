# EZNetworking

AwesomeSwiftPackage is a Swift package that provides a set of awesome utilities to make Swift development easier and more fun. It includes various extensions, custom UI components, and helper functions.


## Installation

### Swift Package Manager

To integrate EZnetworking into your Xcode project using Swift Package Manager, add the following dependency to your Package.swift file:

swift
Copy code
```
dependencies: [
    .package(url: "https://github.com/Aldo10012/EZNetworking.git", from: "1.0.0")
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


#### How do I set custom headers if not handled by `HTTPHeader`?

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

You can easily execute Requests using `RequestPerformerImpl()` It can manage error handling and is capable of performing requests and returning responses using Async/Await and Completion Handlers.

#### How to get an api response using `Async/Await`?
```swift
func asyncMethodName() async throws {
    let request = RequestBuilder().build(httpMethod: .GET, urlString: "http://www.example.com", parameters: [])!
    let performer = RequestPerformerImpl()
    
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
    let performer = RequestPerformerImpl()
    
    do {
        let person = try await performer.perform(request: request)
        print("Did succeed")
    } catch let error as NetworkingError {
        print(error)
    }
}
```


#### How to get an api response using completion handlers?
```swift
let request = RequestBuilder().build(httpMethod: .GET, urlString: "http://www.example.com", parameters: [])
let performer = RequestPerformerImpl()
performer.perform(request: request, decodeTo: Person.self) { result in
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
let request = RequestBuilder().build(httpMethod: .GET, urlString: "http://www.example.com", parameters: [])
let performer = RequestPerformerImpl()
performer.perform(request: request) { result in
    switch result {
    case .success:
        print("did succeed")
    case .failure(let error):
        print(error)
    }
}
```
