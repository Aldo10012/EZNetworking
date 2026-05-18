# EZNetworking

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS_17+_|_macOS_14+_|_watchOS_10+_|_tvOS_17+_|_visionOS_1+-blue.svg)](https://developer.apple.com/)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

EZNetworking is a powerful, lightweight Swift networking library that simplifies API interactions in your Apple platform applications. Built with modern Swift features, it provides an intuitive interface for making HTTP requests, handling responses, and managing network operations.

## Key Features 🚀

- **Modern Swift Support**: Built with Swift 5.9 and iOS 17.0+, macOS 14.0+, watchOS 10.0+, tvOS 17.0+, visionOS 1.0+
- **Async/Await Integration**: First-class support for Swift concurrency
- **AsyncStream Support**: Streaming progress for uploads, downloads, and real-time events
- **Type-Safe Networking**: Strong typing for requests and responses
- **Flexible Request Building**: Multiple approaches to creating requests
- **Comprehensive Interceptors**: Full request/response pipeline control
- **Cache Control**: Configurable `URLRequest` cache policies and optional cache interceptors
- **File Download**: Easy-to-use file downloader
- **File Upload**: Easy-to-use file uploader
- **Data Upload**: Easy-to-use data uploader
- **Multipart Form Data**: Construct multipart requests with boundary handling and MIME types
- **WebSocket**: Real-time, bi-directional client-to-server communication
- **Server-Sent Events**: Lightweight, server-to-client streaming with automatic reconnection
- **Extensive Testing**: Comprehensive unit test suite

## Table of Contents 📑

- [Installation](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#installation-)
- [Quick Start Guide](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#quick-start-guide-)
- Usage
  - HTTP Components - [HTTP Method](Documentation/01_httpComponents.md#http-methods), [HTTP Query Parameter](Documentation/01_httpComponents.md#query-parameters), [HTTP Header](Documentation/01_httpComponents.md#headers), [HTTP Body](Documentation/01_httpComponents.md#request-body), [Timeout](Documentation/01_httpComponents.md#timeout), [Cache](Documentation/01_httpComponents.md#cache)
  - How to make a request - [RequestFactory](Documentation/02_howToMakeARequest.md#using-requestfactory), [RequestBuilder](Documentation/02_howToMakeARequest.md#using-requestbuilder), [Request protocol](Documentation/02_howToMakeARequest.md#request-protocol)
  - How to perform a request - [Performing a Request](Documentation/03_howToPerformARequest.md#performing-a-request), [Error handling](Documentation/03_howToPerformARequest.md#error-handling)
  - Large Data - [File Download](Documentation/04_largeData.md#file-download), [Data Upload](Documentation/04_largeData.md#data-upload), [File Upload](Documentation/04_largeData.md#file-upload), [Multipart-form Upload](Documentation/04_largeData.md#multipart-form-upload)
  - Live Communication - [server-sent-event](Documentation/05_liveConnumication.md#server-sent-events), [websocket](Documentation/05_liveConnumication.md#websocket)
  - Session Management - [Session](Documentation/06_sessionManagement.md#session), [SessionDelegate](Documentation/06_sessionManagement.md#sessiondelegate), [Interceptors](Documentation/06_sessionManagement.md#interceptors)
- [Scripts](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#scripts)
- [Contributing](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#contributing-)
- [License](https://github.com/Aldo10012/EZNetworking?tab=readme-ov-file#license-)

## Installation 📦

### Swift Package Manager

Add EZNetworking to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/Aldo10012/EZNetworking.git", from: "5.6.0")
]
```

Or through Xcode:
1. Go to File > Add Packages
2. Enter: `https://github.com/Aldo10012/EZNetworking.git`
3. Select version: 5.5.3 or later

## Quick Start Guide 🚀

Here's a simple example to get you started:

```swift
// Create a request
let request = RequestFactoryImpl().build(
    httpMethod: .GET,
    baseUrlString: "https://api.example.com/data",
    parameters: [.init(key: "userId", value: "123")]
)

// Using async/await
do {
    let response = try await RequestPerformer().perform(
        request: request,
        decodeTo: UserData.self
    )
    print("User data: \(response)")
} catch {
    print("Error: \(error)")
}
```

## Scripts

`swiftformat Sources Tests`

- Automatically formats the Swift code according to the rules defined in .swiftformat configuration file.

`swiftlint Sources Tests`

- Analyzes the Swift code and reports violations of the rules defined in .swiftlint.yml configuration file.

`swiftlint --fix Sources Tests`

- Automatically fixes auto-correctable SwiftLint violations in the code.



## Contributing 🤝

Contributions are always welcome! For more details see [CONTRIBUTING.md](CONTRIBUTING.md).

## License 📄

EZNetworking is available under the MIT license. See the [LICENSE](https://github.com/Aldo10012/EZNetworking?tab=MIT-1-ov-file) file for more info.
