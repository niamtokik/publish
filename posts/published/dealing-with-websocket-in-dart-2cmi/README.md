---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/dealing-with-websocket-in-dart-2cmi"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fkrpwfh4dnlkgxulm72r5.jpg"
created_at: "None"
crossposted_at: "None"
description: "WebSocket is a protocol created more than 10 years ago offering a bidirectional communication channel..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/dealing-with-websocket-in-dart-2cmi"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "dealing-with-websocket-in-dart-2cmi"
social_image: "None"
title: "Dealing with WebSocket in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Dealing with WebSocket in Dart

WebSocket is a protocol created more than 10 years ago offering a bidirectional communication channel between a client and a server. It fixes the HTTP polling issue.

> The WebSocket Protocol attempts to address the goals of existing bidirectional HTTP technologies in the context of the existing HTTP infrastructure; as such, it is designed to work over HTTP ports 80 and 443 as well as to support HTTP proxies and intermediaries, even if this implies some complexity specific to the current environment.  However, the design does not limit WebSocket to HTTP, and future implementations could use a simpler handshake over a    dedicated port without reinventing the entire protocol.  This last point is important because the traffic patterns of interactive messaging do not closely match standard HTTP traffic and can induce unusual loads on some components.
>
> -- [RFC6455, section 1](https://datatracker.ietf.org/doc/html/rfc6455#section-1)

Today, let have some fun with WebSocket in Dart

# WebSocket Server with `shelf`

Unfortunately, like most of the modern language, there is a framework war. Many different implementation exists for doing the same thing. I don't really have time to check all of them, so, I will just do quick table. All of them are supporting WebSockets.

| package | version | framework? | deprecated? | notes |
|---------|---------|------------|-------------|-------|
| [`shelf`](https://pub.dev/packages/shelf) | 1.4.2 | no | no | maintained by dart team
| [`http_server`](https://pub.dev/packages/http_server) | 1.0.0 | no | yes | previous official http server
| [`frog`](https://pub.dev/packages/dart_frog) | 1.2.6 | yes | no | minimalist backend framework
| [`shelf_easy`](https://pub.dev/packages/shelf_easy) | 5.2.0 | yes | no | lightweight framework
| [`darto`](https://pub.dev/packages/darto) | 0.0.35 | yes | no | micro-web framework
| [`serinus`](https://pub.dev/packages/serinus) | 2.1.12 | yes | no | flexible framework
| [`alfred`](https://pub.dev/packages/alfred) | 1.1.3 | yes | no | expressjs like web server
| [`vania`](https://pub.dev/packages/vania) | 1.1.5 | yes | yes | high-performance framework
| [`finch`](https://pub.dev/packages/finch) | 1.3.2 | yes | no | lightweight framework (looks popular)

Most of them are using `shelf` or `http_server` as backend, not sure if it's really necessary to test them all one by one. Anyway, I will use [`shelf`](https://pub.dev/packages/shelf) for one reason: this is not a framework, and it is maintained by the Dart team. I'm a bit sad though, because I can't find a lot of documentation, except the [official API](https://pub.dev/documentation/shelf/latest/). To use WebSocket with `shelf`, the [`shelf_web_socket`](https://pub.dev/packages/shelf_web_socket) handler is required, again, only the [API documentation](https://pub.dev/documentation/shelf_web_socket/latest/shelf_web_socket/) can easily be found. A full example can be found in [`server/simple`](https://github.com/dart-lang/samples/tree/main/server/simple) directory from [dart source code](https://github.com/dart-lang).

For this exercise, I would like to have something simple:

- long living foreground process
- listening on `127.0.0.0:8080`
- only one route: `/`
- all other routes are redirected to `/`
- automatic support of web socket
- echo all message sent by the client

No authentication, no encryption, just a simple websocket echo server. First, let try to understand how to use `shelf`. What kind of packages will be needed there?

- [`shelf`](https://pub.dev/documentation/shelf/latest/shelf/) from the [`shelf`](https://pub.dev/packages/shelf) package. It includes different kind of helpful classes to deal with the server, like [`Cascade`](https://pub.dev/documentation/shelf/latest/shelf/Cascade-class.html) (managing handlers), [`Pipeline`](https://pub.dev/documentation/shelf/latest/shelf/Pipeline-class.html) to compose [Middleware](https://pub.dev/documentation/shelf/latest/shelf/Middleware.html)s and [Handler](https://pub.dev/documentation/shelf/latest/shelf/Handler.html)s, [`Request`](https://pub.dev/documentation/shelf/latest/shelf/Request-class.html) to give an abstract view of a request, [`Response`](https://pub.dev/documentation/shelf/latest/shelf/Response-class.html) to offers an interface for the HTTP response returned and finally [`Server`](https://pub.dev/documentation/shelf/latest/shelf/Server-class.html) as [adapter](https://github.com/dart-lang/shelf#adapters). We will see that probably later.

- [`shelf_io`](https://pub.dev/documentation/shelf/latest/shelf_io/) from the [`shelf`](https://pub.dev/packages/shelf) package. This one is an adapter, mostly used to handle [`HttpRequest`](https://api.dart.dev/stable/3.11.5/dart-io/HttpRequest-class.html), if one wants to create a quick and dirty http server, one can use the [`server()`](https://pub.dev/documentation/shelf/latest/shelf_io/serve.html) method.

- [`shelf_router`](https://pub.dev/documentation/shelf_router/latest/) from the [`shelf_router`](https://pub.dev/packages/shelf_router) package. This is a routing library designed for `shelf`, offering [`Route`](https://pub.dev/documentation/shelf_router/latest/shelf_router/Route-class.html) and [`Router`](https://pub.dev/documentation/shelf_router/latest/shelf_router/Router-class.html) classes to deal with HTTP path routing. In our case, it will be only used to redirect all path to `/`.

- [`shelf_web_socket`](https://pub.dev/documentation/shelf_web_socket/latest/) from the [`shelf_web_socket`](https://pub.dev/packages/shelf_web_socket) package. Well, it has already be described before, this is an handler to deal with WebSockets.

- [`web_socket_channel`](https://pub.dev/documentation/web_socket_channel/latest/) package, mostly used for few exposed classes.

Knowing that, here the headers used to deal with a simple `shelf` WebSocket server:

```dart
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:ws/ws.dart' as ws;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
```

To create a WebSocket handler, a callback function is required, it is called `onConnection` in the implementation. This function is taking 2 arguments, the first one is a [`WebSocketChannel`](https://pub.dev/documentation/web_socket_channel/latest/web_socket_channel/WebSocketChannel-class.html) object, and the second argument is a `String` representing an eventual WebSocket subprotocol.

```dart
void _onConnection(WebSocketChannel webSocket, String? subprotocol) {
  webSocket.sink.add('{"msg":"ready"}\n');
  webSocket.stream.listen((message) {
    print('received: "$message"');
    webSocket.sink.add('{"msg":"$message"}\n');
  });
}
```

The `WebSocketChannel` object got 2 interesting properties:

- [`sink`](https://pub.dev/documentation/web_socket_channel/latest/web_socket_channel/WebSocketChannel/sink.html) - an instance of the [`Sink`](https://api.dart.dev/dart-core/Sink-class.html) class - used to send value to the client, it can be used also to close the connection with the [`close()`](https://pub.dev/documentation/web_socket_channel/latest/web_socket_channel/WebSocketChannel/sink.html) method. Then, in `onConnection()` function, when the connection is ready, the server is sending a first message.

- [`stream`](https://pub.dev/documentation/web_socket_channel/latest/web_socket_channel/WebSocketChannel/stream.html) - an instance of the [`Stream`](https://api.dart.dev/dart-async/Stream-class.html) class - used to receive the message emitted by the client. In `onConnection()` function, every time a client is sending a message, the server will print the message locally on STDOUT and will return the same message to the client.

```dart
Handler _webSocketHandler1() {
  return webSocketHandler(
    _onConnection,
    protocols: null,
    allowedOrigins: null,
    pingInterval: Duration(seconds: 30)
  );
}
```

A dedicated function to start this first test is also required. Let call it `startShelfIO` where `shelf_io` will be used to start the server using [`serve()`](https://pub.dev/documentation/shelf/latest/shelf_io/serve.html) method.

```dart
void startShelfIO() {
  shelf_io
    .serve(_webSocketHandler1(), 'localhost', 8080)
    .then((server) {
      print('server started');
    });
}
```

Finally the `main()` function, it will simply invoke `startShelfIO()` function and do nothing more.

```dart
void main(List<String> arguments) {
  startShelfIO();
}
```

Hmm. We don't have a WebSocket client available right, it will be coded in the next part of this article. Unluckily, `curl` does not have a full support for the WebSocket protocol (it can receive but not send data). Instead, we can install the [`browser-websocket-client`](https://github.com/abeade/browser-websocket-client) open-source plugin available on the [Chrome Web Store](https://chromewebstore.google.com/detail/browser-websocket-client/mdmlhchldhfnfnkfmljgeinlffmdgkjo). Are you Firefox friendly? You can use [Weasel](https://addons.mozilla.org/en-US/firefox/addon/websocket-weasel/) and its still [open-source](https://github.com/mhgolkar/Weasel). If you prefer a command line tool, you can also check [`websocat`](https://github.com/vi/websocat) or [`claws`](https://github.com/thehowl/claws).

```console
$ dart run
Building package executable... 
Built ws:ws.
server started
received: "{"client": "test"}"
```

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/olrgs7s34yyt6himly67.png)

It seems to works... What if we want to close the connection from the server side? Simply [`close()`](https://pub.dev/documentation/web_socket_channel/latest/web_socket_channel/WebSocketSink/close.html) the sink.

```dart
webSocket.sink.close();
```

To do something before closing the connection or if the client is closing it on its side, the `onDone` attribute can be set while invoking the [`listen()`](https://api.dart.dev/stable/3.11.5/dart-async/Stream/listen.html) method.

> If this stream closes and sends a done event, the `onDone` handler is called. If `onDone` is `null`, nothing happens.
>
> -- [listen abstract method](https://api.dart.dev/stable/3.11.5/dart-async/Stream/listen.html)

Am I following the best practices here? Absolutely not! But if you want to fix my mess and add many layers of security, here a small list of references to do that:

- [WebSocket Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/WebSocket_Security_Cheat_Sheet.html) by the OWASP Team;

- [WebSocket architecture best practices: Designing scalable realtime systems](https://ably.com/topic/websocket-architecture-best-practices) by Ably

- [WebSocket Best Practices for Production Applications](https://websocket.org/guides/best-practices/) from WebSocket.org

- [WebSocket Security Testing: Penetration Test Cases & Best Practices](https://medium.com/@mahendra.mb06/websocket-security-testing-penetration-test-cases-best-practices-c34c22303275) by [Mahendra Mb
](https://medium.com/@mahendra.mb06)

- [WebSocket: Best Practices](https://mangohost.net/blog/websocket-best-practices/) by MongoHost

If you simply see other implementation or read more about WebSockets server on Dart:

- [Create a WebSocket Server with Dart](https://mojoauth.com/websocket/create-a-websocket-server-with-dart/#setting-up-the-websocket-server) by MojoAuth

- [Working with WebSocket](https://dev.to/itzmeanjan/working-with-websocket-10gh) by @itzmeanjan 


# WebSocket Client with `web_socket`

I will not do the same error twice and start to check all frameworks/implementations to deal with a WebSocket client in Dart. The first one available is the [`web_socket`](https://pub.dev/packages/web_socket) package. This one is directly maintained by the Dart team and the source code can be seen in [`pkgs/web_socket`](https://github.com/dart-lang/http/tree/master/pkgs/web_socket). An unique [example](https://github.com/dart-lang/http/blob/master/pkgs/web_socket/example/web_socket_example.dart) is also available. The previous package called [`web_socket_channel`](https://pub.dev/packages/web_socket_channel) was the one used by most of the project, but due to the complexity, a simpler one was required.

```console
$ dart pub add web_socket
Resolving dependencies... 
Downloading packages... 
  web_socket 1.0.1 (from transitive dependency to direct dependency)
Changed 1 dependency!
```

Only the `web_socket` package will be required here. Note: to make things easier, just create a new dart file like `bin/wsc.dart`.

```dart
import 'package:web_socket/web_socket.dart';
```

Let create an isolated function called `webSocketClient` to deal with the socket initialization.

```dart
void webSocketClient() async {
  final socket = 
    await WebSocket.connect(
      Uri.parse('ws://localhost:8080/')
    );
  socket.sendText('hello');
  socket.events.listen(
    (event) async {
      switch (event) {
        case TextDataReceived(text: final text):
          print("$text");
        case BinaryDataReceived(data: final data):
          print("$data");
        case CloseReceived(code: final code, reason: final reason):
          print("$code, $reason");
      }
      socket.close();
    }
  );
}
```

- The [`connect()`](https://pub.dev/documentation/web_socket/latest/web_socket/WebSocket/connect.html) static method is called with the URL of the server using an [`Uri`](https://api.dart.dev/dart-core/Uri-class.html) object. It returns a [`Future<WebSocket>`](https://pub.dev/documentation/web_socket/latest/web_socket/WebSocket-class.html) object.

- [`sendText()`](https://pub.dev/documentation/web_socket/latest/web_socket/WebSocket/sendText.html) method is then invoked to send a text message to the server. If binaries are required, then use [`sendBytes()`](https://pub.dev/documentation/web_socket/latest/web_socket/WebSocket/sendBytes.html) method. It returns nothing and in case of disconnection, the messages are silently discarded.

- The [`WebSocketEvent`](https://pub.dev/documentation/web_socket/latest/web_socket/WebSocketEvent-class.html) class is then used to deal with the events received on the socket. Those events are usually messages sent by the server, they can are defined in three different classes:

  - a [`TextDataReceived`](https://pub.dev/documentation/web_socket/latest/web_socket/TextDataReceived-class.html) object is returned when the server is sending text message (e.g. [JSON](https://www.json.org/json-en.html)). 

  - a [`BinaryDataReceived`](https://pub.dev/documentation/web_socket/latest/web_socket/BinaryDataReceived-class.html) object is returned when the server is sending binary message (e.g. [protobuf](https://protobuf.dev/), [CBOR](https://cbor.io/)).

  - a [`CloseReceived`](https://pub.dev/documentation/web_socket/latest/web_socket/CloseReceived-class.html) object is finally returned when the connection is closed.

- The [`close()`](https://pub.dev/documentation/web_socket/latest/web_socket/WebSocket/close.html) method is called to explicitly close the connection from the client side.

The client side here is quite simple, and does not involve complex procedure. To invoke it, just execute the `webSocketClient()` function in the `main()` entry-point.

```dart
void main() async {
  webSocketClient(socket);
}
```

Time to test if it is working correctly

```console
$ dart run bin/wsc.dart
{"msg":"ready"}
```

It seems to work. The client connects to the server, return the message received and simply close the connection.

Another popular WebSocket client package called [`web_socket_client`](https://pub.dev/packages/web_socket_client) is also available at pub.dev. I'm not really sure if it adds more features or is more flexible than the default [WebSocket client](https://pub.dev/packages/web_socket) maintained by the Dart team. If you are interested to see more implementations and examples, here a quick list:

- [Official example](https://github.com/dart-lang/http/blob/master/pkgs/web_socket/example/web_socket_example.dart)

- [Dart WebSocket](https://www.zetcode.com/dart/websocket/) on ZetCode

- [Building a WebSocket Client in Flutter: From Zero to Hero](https://medium.com/@punithsuppar7795/building-a-websocket-client-in-flutter-from-zero-to-hero-30d945dc7722) by [Punith S Uppar](https://medium.com/@punithsuppar7795)

- [Real-time apps with Flutter and WebSockets](https://medium.com/somnio-software-flutter-agency/real-time-apps-with-flutter-and-websockets-83b957a74d01) by [Gianfranco Papa](https://medium.com/@gianfrancopapa)

# Conclusion

Creating a WebSocket client and a WebSocket server was not so hard, even if the documentation is hard to find, and most of the examples are limited to simple use cases. The subprotocol feature present in WebSocket is kinda interesting and I think I will work on that on another post. Again, the code presented above was made for test purpose only, I can't recommend anyone to use it in production environment.

Anyway, I think in a future publication, we will create something a bit more complex, like creating a custom communication protocol between a client and a server, using binary data.

----

Cover Image by <a href="https://unsplash.com/@andknech?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Andrew Knechel</a> on <a href="https://unsplash.com/photos/macro-view-of-lights-in-a-party-in-gettysburg-gG6yehL64fo?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
      