# Live Communication

## Server-Sent Events

Server-Sent Events (SSE) provide lightweight, server-to-client streaming over HTTP. Unlike WebSockets, SSE is uni-directional — the server pushes events to the client.

### How to initialize

**Using URL**

You can initialize `ServerSentEventManager` using a plain url string

```swift
let sse = ServerSentEventManager(url: "https://example.com/events")
```

**Using SSERequest**

`SSERequest` is an implementation of the `Request` protocol that is specifically designed for connecting to SSE streams.
It takes the following as init arguments:

- `url: String` - Required - the SSE endpoint url
- `additionalHeaders: [HTTPHeader]?` - Optional - any additional headers you need for your SSE request

The following headers are automatically set: `Accept: text/event-stream`, `Cache-Control: no-cache`, `Connection: keep-alive`.

Example:

```swift
let request = SSERequest(
    url: "https://example.com/events",
    additionalheaders: [
        .authorization(.bearer("YOUR_TOKEN"))
    ]
)
let sse = ServerSentEventManager(request: request)
```

### How to connect

The `.connect()` method initiates the SSE connection

```swift
try await sse.connect()
```

### How to disconnect

The `.disconnect()` method closes the active connection. This DOES NOT end the `events` or `stateEvents` streams.

Use this method if you want to be able to reconnect by calling `.connect()` again. On reconnect, the `Last-Event-ID` header is automatically sent.

```swift
try await sse.disconnect()
```

### How to terminate

The `.terminate()` method closes the connection and finishes all streams. Reconnection is not possible after this.

Use this method when you are officially done using the SSE connection.

```swift
await sse.terminate()
```

### How to receive events

The `.events` stream allows you to observe incoming server-sent events

```swift
for await event in await sse.events {
    print(event.id)    // optional event ID
    print(event.event) // optional event type/name
    print(event.data)  // event payload
    print(event.retry) // optional server-suggested retry interval (ms)
}
```

### How to observe state

The `.stateEvents` stream allows you to observe connection state changes

```swift
for await state in await sse.stateEvents {
    switch state {
    case .notConnected:
        // initial idle state before connecting
    case .connecting:
        // connection is being established
    case .connected:
        // successfully connected to SSE stream
    case .disconnected(let reason):
        switch reason {
        case .streamEnded:
            // server closed the stream normally
        case .streamError(let error):
            // unexpected error
        case .manuallyDisconnected:
            // client called disconnect()
        case .terminated:
            // client called terminate()
        }
    }
}
```

### Retry policy

You can configure automatic reconnection with exponential backoff by passing a `RetryPolicy`.

```swift
let retryPolicy = RetryPolicy(
    enabled: true,
    maxAttempts: 5,            // nil = unlimited retries
    initialDelay: 1.0,         // seconds before first retry
    maxDelay: 60.0,            // maximum delay cap
    backoffMultiplier: 2.0     // delays: 1s, 2s, 4s, 8s, 16s, ...
)

let sse = ServerSentEventManager(
    url: "https://example.com/events",
    retryPolicy: retryPolicy
)
```

If the server sends a `retry:` field in an event, that value is used as the delay for the first reconnection attempt.

### Callback adapter

If you prefer closures over async/await, use `ServerSentEventCallbackAdapter`:

```swift
let sse = ServerSentEventCallbackAdapter(url: "https://example.com/events")

sse.onEvent { event in
    print(event.data)
}

sse.onStateChange { state in
    print(state)
}

sse.connect { result in
    switch result {
    case .success:
        // connected
    case .failure(let error):
        // handle error
    }
}

// disconnect
sse.disconnect { result in
    switch result {
    case .success:
        // disconnected
    case .failure(let error):
        // handle error
    }
}

// terminate
sse.terminate()
```

### Combine adapter

If you prefer using the Combine framework, use `ServerSentEventPublisherAdapter`:

```swift
var cancellables = Set<AnyCancellable>()

let sse = ServerSentEventPublisherAdapter(url: "https://example.com/events")

sse.events
    .sink { event in
        print(event.data)
    }
    .store(in: &cancellables)

sse.stateEvents
    .sink { state in
        print(state)
    }
    .store(in: &cancellables)

sse.connect()
    .sink(receiveCompletion: { completion in
        // handle completion
    }, receiveValue: {
        // connected
    })
    .store(in: &cancellables)
```

## WebSocket

WebSockets are used to establish bi-directional, real-time communication between a client and server.

### How to initialize

**Using URL**

You can initialize WebSocket using a plain url string

```swift
let ws = WebSocket(url: "ws://127.0.0.1:8080/example")
```

**Using WebSocketRequest**

`WebSocketRequest` is an implementation of the `Request` protocol that is specifically designed for connecting to WebSockets.
It takes the following as init arguments:

- `url: String` - Required - the string of the web socket url you are trying to connect to.
- `protocols: [String]?` - Optional - list of strings that will be used for the `Sec-WebSocket-Protocol` header
- `additionalHeaders: [HTTPHeader]?` - Optional - any additional header you need for your web socket request

Example:

```swift
let request = WebSocketRequest(
    url: "ws://127.0.0.1:8080/example"
    protocols: ["chat"],
    additionalheaders: [
        .contentType(.json)
        .authentication(.bearer("token"))
    ]
)
let ws = WebSocket(request: request)
```

**Adding PingConfig**

Both init methods of `WebSocket` also takes a `PingConfig`, which is used to control ping-pong logic.
It takes the following as init arguments:
- `pingInterval: IntervalDuration` - how often ping message gets sent to server (to keep connection alive)
- `maxPingFailures: UInt` - max number of times ping-pong fail before disconnecting

```swift
let congif = PingConfig(pingInterval: .seconds(30), maxPingFailures: 3)

let ws1 = WebSocket(url:_, pingConfig: pingConfig)
let ws2 = WebSocket(request:_, pingConfig: pingConfig)
```

### How to connect

The `.connect()` method is used to establish websocket handshake

```swift
try await ws.connect()
```

### How to disconnect

The `.disconnect()` method sends a close-frame, ending websocket handshake. This DOES NOT end messages or stateEvent streams.

Use this method if you want to be able to reconnect to the web socket by calling `.connect()` again.

```swift
try await ws.disconnect()
```

### How to terminate

The `.terminate()` method sends a close-frame, ending websocket handshake. This DOES end messages or stateEvent streams.

Use this method when you are officially done using WebSocket and do not plan on reconnecting

```swift
try await ws.terminate()
```

### How to send messages

The `.send(_)` method allows you to send a message to the websocket

```swift
/// sending string message
try await ws.send(.string("some string message"))

/// sending data message
try await ws.send(.data("some data message".data(using: .utf8)))
```

### How to receive messages

The `.messages` stream allows you to observe incoming messages from the websocket

```swift
for await message in await sut.messages {
    switch message {
    case .string(let msg):
        // handle string messages
    case .data(let msg):
        // handle data messages
    }
}
```

### How to observe state

The `.stateEvents` stream allows you to observe state changes

```swift
for await state in await sut.stateEvents {
    switch state {
        case .notConnected:
            // handle notConnected state (initial idle state before connecting to socket)
        case .connecting:
            // handle connecting state (socket is in process of connecting)
        case .connected(protocol: _):
            // handle connected state (socket successfully connected)
        case .disconnected(_):
            // handle disconnected state (socket lost connection. Due to user manual disconnect or server connection lost)
    }
}
```

### Callback adapter

If you prefer closures over async/await, use `WebSocketCallbackAdapter`:

```swift
let ws = WebSocketCallbackAdapter(url: "ws://127.0.0.1:8080/example")

ws.onMessage { message in
    switch message {
    case .string(let msg):
        // handle string messages
    case .data(let msg):
        // handle data messages
    }
}

ws.onStateChange { state in
    print(state)
}

ws.connect { result in
    switch result {
    case .success:
        // connected
    case .failure(let error):
        // handle error
    }
}

// send a message
ws.send(.string("hello")) { result in
    switch result {
    case .success:
        // message sent
    case .failure(let error):
        // handle error
    }
}

// disconnect (can reconnect later)
ws.disconnect { result in
    switch result {
    case .success:
        // disconnected
    case .failure(let error):
        // handle error
    }
}

// terminate (permanent shutdown)
ws.terminate()
```

### Combine adapter

If you prefer using the Combine framework, use `WebSocketPublisherAdapter`:

```swift
var cancellables = Set<AnyCancellable>()

let ws = WebSocketPublisherAdapter(url: "ws://127.0.0.1:8080/example")

ws.messages
    .sink { message in
        switch message {
        case .string(let msg):
            // handle string messages
        case .data(let msg):
            // handle data messages
        }
    }
    .store(in: &cancellables)

ws.stateEvents
    .sink { state in
        print(state)
    }
    .store(in: &cancellables)

ws.connect()
    .sink(receiveCompletion: { completion in
        // handle completion
    }, receiveValue: {
        // connected
    })
    .store(in: &cancellables)

// send a message
ws.send(.string("hello"))
    .sink(receiveCompletion: { completion in
        // handle completion
    }, receiveValue: {
        // message sent
    })
    .store(in: &cancellables)
```
