---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/low-level-http-client-in-dart-4d3"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fkn02c09cof4ub74yu7c0.jpg"
created_at: "None"
crossposted_at: "None"
description: "Dealing with HTTP requests is also learning a lot about network issues and distributed data problems...."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/low-level-http-client-in-dart-4d3"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "low-level-http-client-in-dart-4d3"
social_image: "None"
title: "Low Level HTTP Client in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Low Level HTTP Client in Dart

Dealing with HTTP requests is also learning a lot about network issues and distributed data problems. Indeed, HTTP requires a connection, it can be a local one (useful only if you want to test or deal with private stuff) or a remote one (way better to fetch data from the web).

Dart offers a low-level interface to an HTTP Client called [`HttpClient`](https://api.dart.dev/dart-io/HttpClient-class.html). It could be nice to try it first and then find a decent alternative like the [http package](https://pub.dev/packages/http). Let call this new project `httpcat` a small command line HTTP client. The idea is to simple create a connection to a remote server and print the returned data with the headers. here an example:

```shell
$ httpcat ${target}
```

Where `${target}` is a valid URL using HTTP or HTTPS protocol.

```sh
dart create httpcat
cd httpcat
```

Let create a new project from scratch with `dart create` command and start edit the entry-point in `bin/httpcat.dart`. Before doing anything, one should probably read some unit test first, the ones present in [`tests/standalone/io/http_client_request_test.dart`](https://github.com/dart-lang/sdk/blob/main/tests/standalone/io/http_client_request_test.dart) for example.

```dart
import 'package:httpcat/httpcat.dart' as httpcat;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:core';
```

First we will need to import few packages:

- [`dart:io`](https://dart.dev/libraries/dart-io) is required for the HttpClient class;

- [`dart:async`](https://dart.dev/libraries/dart-async) is required for the concurrency execution of the request, it could be optional here though, but the next part of the code will reuse a part of the examples provided by the Dart documentation;

- [`dart:convert`](https://dart.dev/libraries/dart-convert) is required for `utf8` conversion support, again, it could be optional, but it's important because of the example provided by the Dart documentation.

- [`dart:core`](https://dart.dev/libraries/dart-core) will be used for string conversion with utf8

```dart
void main(List<String> arguments) {
  getUrl();
}
```

The the `main()` function can be created. This time, a list of arguments can be passed via the command line and stored in the `arguments` variable. Not used yet though. This entry-point will then call `getUrl()` function defined in the next part of the article.

```dart
void getUrl() async {
  var host = 'localhost';
  var port = 8080;
  var path = '/file.txt';
  var client = HttpClient(); 
  try {
    HttpClientRequest request = await client.get(host, port, path);
    HttpClientResponse response = await request.close();
    final stringData = await response
      .transform(utf8.decoder)
      .join();
    print(stringData);
  }
  finally {
    client.close();
  }
}
```

The first part of the code defines some variables for the targets, the `host`, the `port` and the `path`. Then, an HTTP client object is created using `HttpClient` class.

The connection procedure starts really after the [`try` clause](https://dart.dev/language/error-handling#catch) used to catch exceptions:

1. an asynchronous http client request is started using [`get()`](https://api.dart.dev/dart-io/HttpClient/get.html) method and the information previously configured in the variables. It returns an [HttpClientRequest](https://api.dart.dev/dart-io/HttpClientRequest-class.html) object.

2. the code is waiting for an asynchronous response from the server. The response is given with the help of the [`close()`](https://api.dart.dev/dart-io/HttpClientRequest/close.html) method and returns an [`HttpClientResponse`](https://api.dart.dev/dart-io/HttpClientResponse-class.html) object.

3. If the response is correct (and you will see later the correctness of the response is important here), a [Stream](https://api.dart.dev/dart-async/Stream-class.html) object should now be present in the object and can be transformed with the [`transform()`](https://api.dart.dev/dart-async/Stream/transform.html) method. In this case, the response is converted in utf8 via the [`utf8 decoder()`](https://api.dart.dev/dart-convert/Utf8Codec/decoder.html) method. Last step, the list generated by the transformation is converted as String using the [`join()`](https://api.dart.dev/dart-async/Stream/join.html) method.

4. If everything is fine, the response is printed on stdout.

5. If something goes wrong while waiting for the response, the `finally` block will simply close the connection to the client.

Now is the time to test it and see what this snippet is doing. Let use [`netcat`](https://man.openbsd.org/nc) to listen on a TCP connection locally... 

```sh
nc -kl 8080
```

... and execute `httpcat` with `dart run` command.

```sh
dart run
```

`netcat` is receiving correctly the data from the client and should display something like that:

```http
GET /file.txt HTTP/1.1
user-agent: Dart/3.11 (dart:io)
accept-encoding: gzip
host: localhost:8080
```

What if someone is adding some weird value from the server, like a single character and then press `enter`?

```plaintext
Unhandled exception:
HttpException: Invalid request method, uri = http://localhost:8080/file.txt
#0      _HttpParser._doParse (dart:_http/http_parser.dart:485:15)
#1      _HttpParser._parse (dart:_http/http_parser.dart:353:7)
#2      _HttpParser._onData (dart:_http/http_parser.dart:929:5)
#3      _RootZone.runUnaryGuarded (dart:async/zone.dart:891:10)
#4      _BufferingStreamSubscription._sendData (dart:async/stream_impl.dart:381:11)
#5      _BufferingStreamSubscription._add (dart:async/stream_impl.dart:312:7)
#6      _SyncStreamControllerDispatch._sendData (dart:async/stream_controller.dart:798:19)
#7      _StreamController._add (dart:async/stream_controller.dart:663:7)
#8      _StreamController.add (dart:async/stream_controller.dart:618:5)
#9      _Socket._onData (dart:io-patch/socket_patch.dart:2874:41)
#10     _RootZone.runUnaryGuarded (dart:async/zone.dart:891:10)
#11     _BufferingStreamSubscription._sendData (dart:async/stream_impl.dart:381:11)
#12     _BufferingStreamSubscription._add (dart:async/stream_impl.dart:312:7)
#13     _SyncStreamControllerDispatch._sendData (dart:async/stream_controller.dart:798:19)
#14     _StreamController._add (dart:async/stream_controller.dart:663:7)
#15     _StreamController.add (dart:async/stream_controller.dart:618:5)
#16     new _RawSocket.<anonymous closure> (dart:io-patch/socket_patch.dart:2312:31)
#17     _NativeSocket.issueReadEvent.issue (dart:io-patch/socket_patch.dart:1647:14)
#18     _microtaskLoop (dart:async/schedule_microtask.dart:40:35)
#19     _startMicrotaskLoop (dart:async/schedule_microtask.dart:49:5)
#20     _runPendingImmediateCallback (dart:isolate-patch/isolate_patch.dart:127:13)
#21     _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:194:5)
```

Well, it does not look very good... An exception message is displayed. Let fix that by updating the `try` clause with a `catch`.

```dart
  try {
    // ... no change here
  }
  catch (e) {
    print("outch. something bad happened.");
  }
  finally {
    // ... no change here
  }
```

Restart the application and push some bad data on the server side.

```console
$ dart run
Building package executable... 
Built httpcat:httpcat.
outch. something bad happened.
```

Great! The application is not crashing anymore with a dirty message, but to make things a bit better, we should catch the exception one by one and generate a message for each of them.

## Parsing an URL

The application is now able to fetch something from `localhost`, on port `8080` with a static path `/file.txt`. That's a good step, but it's a bit useless. 

```dart
void getUrl(Uri uri) async {
  // ①
  var host = uri.host;
  var port = uri.port;
  var path = uri.path;

  // ②
  if (uri.host.isEmpty) host = 'localhost';
  if (uri.port.isEmpty) port = 80;
  if (uri.path.isEmpty) path = '/';

  // ③
  var client = HttpClient(); 
  try {
    HttpClientRequest request = await client.get(host, port, path);
    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    print(stringData);
  }
  catch (e) {
    print("outch. something bad happened. $e");
  }
  finally {
    client.close();
  }
}
```

Instead of passing 3 positionals arguments to `getUrl()`, only `uri` is used and represent an Uri object.

① `host`, `port` and `path` variables are configured using attributes from `uri`, respectively `uri.host`, `uri.port` and `uri.path`.

② Dealing with `null` value looks a bit messy on Dart, a [full part of the documentation](https://dart.dev/null-safety/understanding-null-safety#) is dedicated for that. Anyway, it seems the best way is to create guards around those variables and set a default value if they are `null`. Not sure if it's the best method there, but it should work.

③ The rest of the code remains the very same, no modification required.

```dart
void main(List<String> arguments) {
  getUrl('http://localhost:80/');
}
```

The `main()` function can now be updated with the new `getUrl()` function.

## Dealing with Command Line Arguments

Arguments from the command lines are passed to `main()` function as a list of string (`List<String>`). This function is now returning an integer, it will be used by the Unix system as return code. Here the new main function:

```dart
int main(List<String> arguments) {

  // ①
  if (arguments.length != 1) {
    print("Usage: httpcat TARGET");
    return 1;
  }

  // ②
  try {
    var uri = Uri.parse(arguments[0]);
    getUrl(uri);
    return 0;
  }

  // ③
  catch (e) {
    print("bad url. $e");
    return 1;
  }
}
```

① This command is using only one argument, no more. If there is less or more than 1 arguments, usage message is printed and the program stop.

② The program is parsing the URL given from the command line using [`Uri.parse()`](https://api.flutter.dev/flutter/dart-core/Uri/parse.html) method and then use the result with `getUrl()` function. Finally, when this last function returns, the program is stopped.

③ In case of problem (exception), we assume the URL given by the user is bad and the program is stopped.

## Final Code

This whole program is just an example and should not be used in production, but the final result looks like the snippet below.

```dart
import 'package:httpcat/httpcat.dart' as httpcat;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:core';

int main(List<String> arguments) {
  if (arguments.length != 1) {
    print("Usage: httpcat TARGET");
    return 1;
  }

  try {
    var uri = Uri.parse(arguments[0]);
    getUrl(uri);
    return 0;
  }
  catch (e) {
    print("bad url. $e");
    return 1;
  }
}

void getUrl(Uri uri) async {
  var host = uri.host;
  var port = uri.port;
  var path = uri.path;

  if (uri.host.isEmpty) host = 'localhost';
  if (uri.port.isEmpty) port = 80;
  if (uri.path.isEmpty) path = '/';

  var client = HttpClient(); 
  try {
    HttpClientRequest request = await client.get(host, port, path);
    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    print(stringData);
  }
  catch (e) {
    print("outch. something bad happened. $e");
  }
  finally {
    client.close();
  }
}
```

Let try it now.

```console
$ dart run bin/httpcat.dart
Usage: httpcat TARGET

$ dart run bin/httpcat.dart 1 2 3
Usage: httpcat TARGET

$ dart run bin/httpcat.dart http://localhost:8080/
localhost 8080 /
outch. something bad happened. HttpException: Invalid response line, uri = http://localhost:8080/

$ dart run bin/httpcat.dart http://dev.to | head -n 5
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>DEV Community</title>
```

## Conclusion

It looks good! It's not perfect at all, and many things can go wrong, for example, no real check of the `host`, `port` or `path` are made, this is a huge problem. Many other part of the code could be improved, like adding a bit of documentation and so on.

----

Cover Image by <a href="https://unsplash.com/@heytowner?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">JOHN TOWNER</a> on <a href="https://unsplash.com/photos/low-angle-photography-of-highrise-building-p-rN-n6Miag?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>