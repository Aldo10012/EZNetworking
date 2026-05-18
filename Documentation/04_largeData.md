# Large Data

## File Download

`FileDownloader` is an actor-based downloader that supports pause, resume, and cancel. It exposes a single `AsyncStream<DownloadEvent>` API.

### Initialization

`FileDownloader` provides two initializers:

**From a URL string** — the quickest path for a simple GET download:
```swift
let downloader = FileDownloader(url: "https://example.com/file.pdf")
```

**From a `DownloadRequest`** — when you need to attach headers (e.g., authorization) or customize the request:
```swift
let downloader = FileDownloader(
    request: DownloadRequest(
        url: "https://example.com/file.pdf",
        additionalheaders: [.authorization(.bearer("TOKEN"))]
    )
)
```

Both initializers also accept an optional `session: NetworkSession` and `validator: ResponseValidator`. The string-based initializer is a convenience that wraps its argument in a `DownloadRequest` internally, so the two forms are equivalent when no headers are needed.

### Basic Usage
```swift
let downloader = FileDownloader(url: "https://example.com/file.pdf")

for await event in await downloader.downloadFileStream() {
    switch event {
    case .progress(let progress):
        // handle progress (0.0 to 1.0)
    case .completed(let localURL):
        // handle downloaded file at localURL
    case .failed(let error):
        // handle error
        if case .downloadFailed(reason: .failedButResumable) = error {
            // download failed but can be resumed by calling resume()
            try await downloader.resume()
        }
    }
}
```

### Pause, Resume, and Cancel
```swift
let downloader = FileDownloader(url: "https://example.com/file.pdf")

// Start consuming events in a background task
let eventsTask = Task {
    for await event in await downloader.downloadFileStream() {
        // handle events
    }
}

// Pause the download
try await downloader.pause()

// Resume the download
try await downloader.resume()

// Cancel the download
try downloader.cancel()
```

### Background Downloads

To continue downloads when the app is suspended, create a `Session` with a background `URLSessionConfiguration` and inject it into `FileDownloader`:

```swift
let configuration = URLSessionConfiguration.background(withIdentifier: "com.myapp.backgroundDownload")
let session = Session(configuration: configuration)

let downloader = FileDownloader(
    request: DownloadRequest(
        url: "https://example.com/largefile.zip",
        additionalheaders: [.authorization(.bearer("TOKEN"))]
    ),
    session: session
)

for await event in await downloader.downloadFileStream() {
    // handle events
}
```

## Uploads

`FileUploader` and `DataUploader` are actor-based uploaders that conform to `Uploadable`. Both expose the same API: call `upload()` to receive an `AsyncStream<UploadEvent>`, and use `pause()`, `resume()`, and `cancel()` to control the upload.

`FileUploader` uploads from a file on disk using `URLSession`'s `uploadTask(with:fromFile:)`. `DataUploader` writes in-memory `Data` to a temporary file and delegates to an internal `FileUploader`, cleaning up the temp file when the upload finishes or is cancelled. The reason in-memory `Data` is written to a temp file is to support pause/resumem capabilities, which can only be done when uploading data form a file on disk.

### UploadRequest

Configure the destination URL and headers with `UploadRequest`:

```swift
let request = UploadRequest(
    url: "https://example.com/upload",
    additionalheaders: [.authorization(.bearer("TOKEN"))]
)
```

`UploadRequest` always uses `POST` and does not carry a request body. Upload payloads are supplied separately to `FileUploader` or `DataUploader`, because `URLSession` upload tasks read from a file (or resume data) and ignore `URLRequest.httpBody`.

Both uploaders also accept an optional `session: NetworkSession` and `validator: ResponseValidator`.

### Upload events

```swift
for await event in stream {
    switch event {
    case .progress(let progress):
        // 0.0 to 1.0
    case .completed(let responseData):
        // server response body
    case .failed(let error):
        // handle error
    }
}
```

## File Upload

Use `FileUploader` when the payload already exists as a file on disk (bundle resource, documents directory, temp file, etc.):

```swift
let fileURL = Bundle.main.url(forResource: "myDocument", withExtension: "txt")!
// or
let fileURL = URL(fileURLWithPath: "/Users/username/Documents/myFile.pdf")
```

### Basic usage

```swift
let uploader = FileUploader(fileURL: fileURL, request: request)

for await event in await uploader.upload() {
    switch event {
    case .progress(let progress):
        // handle progress
    case .completed(let responseData):
        // handle success
    case .failed(let error):
        // handle error
        if case .uploadFailed(reason: .failedButResumable) = error {
            try await uploader.resume()
        }
    }
}
```

### Pause, resume, and cancel

```swift
let uploader = FileUploader(fileURL: fileURL, request: request)

let eventsTask = Task {
    for await event in await uploader.upload() {
        // handle events
    }
}

try await uploader.pause()
try await uploader.resume()
try await uploader.cancel()
```

When the network fails but URLSession provides resume data, the stream yields `.failed` with `UploadFailureReason.failedButResumable` and stays open so you can call `resume()` and continue receiving events on the same stream.

## Data Upload

Use `DataUploader` to upload `Data` from memory (JSON blobs, encoded models, multipart bodies built in memory, etc.):

```swift
let uploader = try DataUploader(data: payload, request: request)

for await event in await uploader.upload() {
    switch event {
    case .progress(let progress):
        // handle progress
    case .completed(let responseData):
        // handle success
    case .failed(let error):
        // handle error
    }
}
```

`DataUploader` supports the same `pause()`, `resume()`, and `cancel()` methods as `FileUploader`, forwarding them to the underlying file upload.

## Multipart-form upload

Build the multipart body with `MultipartFormData`, then upload it through `DataUploader`:

```swift
let boundary = "SOME_BOUNDARY"

let parts: [MultipartFormPart] = [
    MultipartFormPart.fieldPart(
        name: "username",
        value: "Daniel"
    ),
    MultipartFormPart.filePart(
        name: "profile_picture",
        data: fileData,
        filename: "profile.jpg",
        mimeType: .jpeg
    ),
    MultipartFormPart.dataPart(
        name: "metadata",
        data: Data(encodable: user)!,
        mimeType: .json
    )
]
let multipartFormData = MultipartFormData(parts: parts, boundary: boundary)

guard let body = Data(multipartFormData: multipartFormData) else { return }

let request = UploadRequest(
    url: "https://www.example.com/upload",
    additionalheaders: [
        .contentType(.multipartFormData(boundary: boundary))
    ]
)

let uploader = try DataUploader(data: body, request: request)

for await event in await uploader.upload() {
    switch event {
    case .progress(let progress):
        // handle progress
    case .completed(let responseData):
        // handle success
    case .failed(let error):
        // handle error
    }
}
```

Use the same `boundary` string in both `MultipartFormData` and the `Content-Type` header. Do not assign the multipart body to `UploadRequest` or any other request `body` property—the upload actors pass the payload via `URLSession`'s file-based upload API instead.
