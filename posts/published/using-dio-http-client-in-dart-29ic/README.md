---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/using-dio-http-client-in-dart-29ic"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fvi2g64znpvyd13b8iloe.jpg"
created_at: "None"
crossposted_at: "None"
description: "The low-level HTTP Client and a higher level implementation with the http package have been tested..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/using-dio-http-client-in-dart-29ic"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "using-dio-http-client-in-dart-29ic"
social_image: "None"
title: "Using dio HTTP Client in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Using dio HTTP Client in Dart

The low-level HTTP Client and a higher level implementation with the http package have been tested previously. This time, we will try another high level implementation of an HTTP client in Dart called [`dio`](https://pub.dev/packages/dio). This client seems way more flexible than the previous clients, and embed great features. Furthermore, based on pub.dev, it looks like it's a popular choice. If you are interested to see some examples, you can look into [`example_dart/lib`](https://github.com/cfug/dio/blob/main/example_dart/lib/) directory from their [official repository](https://github.com/cfug/dio). Anyway the first step to use it is to add it in the dependencies.

```console
dart pub add dio
dart pub get
```

This time, instead of of using our own quick and dirty HTTP server using [`netcat`](https://man.openbsd.org/nc.1) or [Python `http.server` module](https://docs.python.org/3/library/http.server.html), let use the free [HTTP Echo Server service](https://beeceptor.com/resources/http-echo/). The idea is to simply creates some requests to this server and print the data returned.

As usual, the first step is to import the package in `bin/httpcat.dart`.
 
```dart
import 'package:dio/dio.dart';
```

Then, let create/configure a `dio` client object using the [Dio](https://pub.dev/documentation/dio/latest/dio/Dio-class.html) class

```dart
final target = 'https://echo.free.beeceptor.com';   
                                                    
final dio = Dio(
  BaseOptions(
    baseUrl: target,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    contentType: null,
    followRedirects: true,
    maxRedirects: 2,
    persistentConnection: false,
    preserveHeaderCase: false,
    // receiveDataWhenStatusError; ...
    // requestEncoder: ...
    // responseDecoder: ...
    // responseType: ...                            
    // sendTimeout: ...                             
    // validateStatus: ...
    headers: {
      HttpHeaders.userAgentHeader: 'dio',
      'x-custom': 'custom'
    },
  )
);
```

The `Dio` class constructor accepts a [`BaseOptions`](https://pub.dev/documentation/dio/latest/dio/BaseOptions-class.html) object, containing the options to configure for the HTTP client. As you can already see in the previous snippet, plenty of attributes are available:

- [`baseUrl`](https://pub.dev/documentation/dio/latest/dio/OptionsMixin/baseUrl.html): set the URL target as `String`. It must be a valid URL;

- [`connectTimeout`](https://pub.dev/documentation/dio/latest/dio/OptionsMixin/connectTimeout.html): the connection timeout out as `int`, when the client is opening a new connection to the remote server. Setting it to `null` or to `Duration.zero` will wait for the connection forever;

- [`contentType`](https://pub.dev/documentation/dio/latest/dio/BaseOptions/contentType.html): set the `Content-Type` HTTP header as a String;

- [`followRedirects`](https://pub.dev/documentation/dio/latest/dio/BaseOptions/followRedirects.html): a Boolean value to define if the client should follow the redirection returned by the server;

- [`maxRedirects`](https://pub.dev/documentation/dio/latest/dio/BaseOptions/maxRedirects.html): the maximum number of redirection the client is allowed to follow defined as `int`;

- [`persistentConnection`](https://pub.dev/documentation/dio/latest/dio/BaseOptions/persistentConnection.html): define if the client should use a persistent connection or not as boolean;

- [`preserveHeaderCase`](https://pub.dev/documentation/dio/latest/dio/BaseOptions/preserveHeaderCase.html): keep the header case unmodified during the request, defined as boolean;

- [`queryParameters`](https://pub.dev/documentation/dio/latest/dio/OptionsMixin/queryParameters.html): set the query parameters of the request as `Map<String, dynamic>`;

- [`receiveDataWhenStatusError`](https://pub.dev/documentation/dio/latest/dio/BaseOptions/receiveDataWhenStatusError.html): I will need to check the code for this one, but I assume when an error is returned, the data received is dropped, if we set this property to `true`, we should then be able to receive the data from the error;

- [`receiveTimeout`](https://pub.dev/documentation/dio/latest/dio/BaseOptions/receiveTimeout.html): set the timeout as a `Duration` for the data sent by the server;

- [`requestEncoder`](https://pub.dev/documentation/dio/latest/dio/BaseOptions/requestEncoder.html): define a custom request encoder using [`RequestEncoder`](https://pub.dev/documentation/dio/latest/dio/RequestEncoder.html) type as function callback. A way to use it, like defined in the tests:

```dart
dio.options.requestEncoder = (data, _) => Future.value(utf8.encode(data));
// or
dio.options.requestEncoder = (data, _) => utf8.encode(data);
```

- [`responseDecoder`](https://pub.dev/documentation/dio/latest/dio/BaseOptions/responseDecoder.html): define a custom response decoder using [`ResponseDecoder`](https://pub.dev/documentation/dio/latest/dio/ResponseDecoder.html) type as function callback. It can be used like the following snippet from the test suite. 

```dart
 dio.options.responseDecoder = (_, __, ___) => null;
// or
dio.options.responseDecoder = (_, __, ___) => Future.value('example');
// or
dio.options.responseDecoder = (_, __, ___) => 'example';
```

- [`responseType`](https://pub.dev/documentation/dio/latest/dio/BaseOptions/responseType.html): set the kind of response wanted by the client. For example, it can be set to `ResponseType.stream`, `ResponseType.plain` or `ResponseType.bytes`.

- [`sendTimeout`](https://pub.dev/documentation/dio/latest/dio/BaseOptions/sendTimeout.html): set the client send timeout, when data is being uploaded to the server;

- [`validateStatus`](https://pub.dev/documentation/dio/latest/dio/BaseOptions/validateStatus.html): set a custom function callback defining if a request status is good or not, using [`ValidateStatus`](https://pub.dev/documentation/dio/latest/dio/ValidateStatus.html) type. Here an example of usage from the test suite, the `status` parameter is an integer representing the HTTP status code.

```dart
validateStatus: (status) => true;
// or
validateStatus: (status) => false;
```

- [`headers`](https://pub.dev/documentation/dio/latest/dio/BaseOptions/headers.html): configure a `Map<String, dynamic>` as HTTP Headers. Standardized HTTP Headers keys can be found in [`HttpHeaders`]( https://api.dart.dev/dart-io/HttpHeaders-class.html#constants) class, defined as constants, for example [`acceptEncodingHeader`](https://api.dart.dev/dart-io/HttpHeaders/acceptEncodingHeader-constant.html) contains the string `accept-encoding`. The code in charge of this part can be seen in [`dio/lib/src/headers.dart`](https://github.com/cfug/dio/blob/main/dio/lib/src/headers.dart), it contains some constants;

After having created a `Dio` object, one can use different way to execute a request, but usually, two conventions can be used, using the `baseUrl` attribute set in the object, or pass it an `Uri` object.

- GET Method
  - [`dio.get(path)`](https://pub.dev/documentation/dio/latest/dio/Dio/get.html) where `path` is a `String`
  - [`dio.getUri(uri)`](https://pub.dev/documentation/dio/latest/dio/Dio/getUri.html) where `uri` is an `Uri` object
- HEAD Method
  - [`dio.head(path)`](https://pub.dev/documentation/dio/latest/dio/Dio/head.html) where `path` is a `String`
  - [`dio.headUri(uri)`](https://pub.dev/documentation/dio/latest/dio/Dio/headUri.html) where `uri` is an `Uri` object
- POST Method
  - [`dio.post(path)`](https://pub.dev/documentation/dio/latest/dio/Dio/post.html) where `path` is a `String`
  - [`dio.postUri(uri)`](https://pub.dev/documentation/dio/latest/dio/Dio/postUri.html) where `uri` is an `Uri` object
- PUT Method
  - [`dio.put(path)`](https://pub.dev/documentation/dio/latest/dio/Dio/put.html) where `path` is a `String`
  - [`dio.putUri(uri)`](https://pub.dev/documentation/dio/latest/dio/Dio/putUri.html) where `uri` is an `Uri` object
- DELETE Method
  - [`dio.delete(path)`](https://pub.dev/documentation/dio/latest/dio/Dio/delete.html) where `path` is a `String`
  - [`dio.deleteUri(uri)`](https://pub.dev/documentation/dio/latest/dio/Dio/deleteUri.html) where `uri` is an `Uri` object
- PATCH Method
  - [dio.patch(path)](https://pub.dev/documentation/dio/latest/dio/Dio/patch.html) where `path` is a `String`
  - [dio.patchUri(uri)](https://pub.dev/documentation/dio/latest/dio/Dio/patchUri.html) where `uri` is an `Uri` object

So, before starting, the `main()` function will be modified to add a `switch` statement, and then, easily test each method from the CLI.

```dart
Future<int> main(List<String> arguments) async {
  if (arguments.length != 1) {
    print("Usage: httpcat TARGET");
    return 1;
  }

  switch (arguments[0]) {
    case "get": return getRequest();
    case "head": return headRequest();
    case "post": return postRequest();
    case "put": return putRequest(); 
    case "delete": return deleteRequest();
    case "patch": return patchRequest();
  }

  Uri? url = parseUrl(arguments[0]);
  if (url == null) return 1;  

  var ret = getUrl(url);
  return ret;
} 
```

Then, the code will be called like that:

```sh
dart run ./bin/httpcat.dart get
```

Another quick modification is required to help seeing the answers from the server. Let create a function called `printResponse()` to print the data from the response.

```dart
void printResponse(Response response) {
  print({
    'status': response.statusCode,
    'status_msg': response.statusMessage,
    'uri': response.realUri,
    'headers': response.headers,
    'data': response.data,
  });
}
```

It will simply print to STDOUT the attributes available in a [`Response`](https://pub.dev/documentation/dio/latest/dio/Response-class.html) object.

# GET Method

Probably one of the most used HTTP request is the [`GET`](https://www.rfc-editor.org/rfc/rfc2616#section-9.3) one.

> The GET method means retrieve whatever information (in the form of an entity) is identified by the Request-URI. If the Request-URI refers to a data-producing process, it is the produced data which shall be returned as the entity in the response and not the source text of the process, unless that text happens to be the output of the process.
>
> -- [RFC2616, section 9.3](https://www.rfc-editor.org/rfc/rfc2616#section-9.3)

`getRequest()` will use [`get()`](https://pub.dev/documentation/dio/latest/dio/Dio/get.html) method to fetch `/`:

```dart
Future<int> getRequest() async {                    
  var response = await dio.get('/');   
  printResponse(response);                                            
  return 0;                                         
}
```

Let run this code to see what it will return from the CLI.

```console
$ dart run bin/httpcat.dart get
{status: 200, status_msg: OK, uri: https://echo.free.beeceptor.com/, headers: connection: close
alt-svc: h3=":443"; ma=2592000
transfer-encoding: chunked
access-control-allow-origin: *
date: Wed, 13 May 2026 12:39:47 GMT
vary: Accept-Encoding
content-type: application/json
via: 1.1 Caddy
, data: {method: GET, protocol: https, host: echo.free.beeceptor.com, path: /, ip: 1.2.3.4:38247, headers: {Host: echo.free.beeceptor.com, User-Agent: dio, Accept-Encoding: gzip, Via: 1.1 Caddy, X-Custom: custom}, parsedQueryParams: {}}}
```

The answer from the server is printed alongside with the status and other information. The return data is a JSON object, containing my - modified - IP address, the headers and so on.

# HEAD Method

> The HEAD method is identical to GET except that the server MUST NOT return a message-body in the response. The metainformation contained in the HTTP headers in response to a HEAD request SHOULD be identical to the information sent in response to a GET request. This method can be used for obtaining metainformation about the entity implied by the request without transferring the entity-body itself. This method is often used for testing hypertext links for validity, accessibility, and recent modification.
>
> -- [RFC2616, section 9.4](https://
www.rfc-editor.org/rfc/rfc2616#section-9.4)

`headerRequest()` function will use [`head()`](https://pub.dev/documentation/dio/latest/dio/Dio/head.html) method and print the response.

```dart
Future<int> headRequest() async {
  var response = await dio.head('/');
  printResponse(response);
  return 0;
}
```

Let execute this function now.

```console
$ dart run bin/httpcat.dart head
{status: 200, status_msg: OK, uri: https://echo.free.beeceptor.com/, headers: connection: close
alt-svc: h3=":443"; ma=2592000
access-control-allow-origin: *
date: Wed, 13 May 2026 12:48:48 GMT
vary: Accept-Encoding
content-type: application/json
via: 1.1 Caddy
, data: null}
```

No data is returned there, it's normal. HTTP Head method does not return any data, like defined in the specifications.

# POST Method

> The POST method is used to request that the origin server accept the entity enclosed in the request as a new subordinate of the resource identified by the Request-URI in the Request-Line. POST is designed to allow a uniform method to cover the following functions:
> - Annotation of existing resources;
> - Posting a message to a bulletin board, newsgroup, mailing list, or similar group of articles;
> - Providing a block of data, such as the result of submitting a form, to a data-handling process;
> - Extending a database through an append operation.
>
> -- [RFC2616, section 9.5](https://
www.rfc-editor.org/rfc/rfc2616#section-9.5)

`postRequest()` function will use `post()` method from the client. A POST request can pass some data, to do that, the string `test_data` is passed to the `data` parameter. The `contentType` attribute must also be updated, because `dio` is intercepting the POST request and will set it to JSON. Let set this to `text/plain`.

```dart
Future<int> postRequest() async {
  dio.options.contentType = 'text/plain';
  var response = await dio.post(
    '/',
    data: 'test_data'
  );
  printResponse(response);
  return 0;
}
```

We can now invoke the command:

```console
$ dart run bin/httpcat.dart post
{status: 200, status_msg: OK, uri: https://echo.free.beeceptor.com/, headers: connection: close
alt-svc: h3=":443"; ma=2592000
transfer-encoding: chunked
access-control-allow-origin: *
date: Wed, 13 May 2026 14:27:11 GMT
vary: Accept-Encoding
content-type: application/json
via: 1.1 Caddy
, data: {method: POST, protocol: https, host: echo.free.beeceptor.com, path: /, ip: 1.2.3.4:40459, headers: {Host: echo.free.beeceptor.com, User-Agent: dio, Content-Length: 9, Accept-Encoding: gzip, Content-Type: text/html, Via: 1.1 Caddy, X-Custom: custom}, parsedQueryParams: {}, rawBody: test_data}}
```

As you can see, the data we have sent is stored in the `rawBody` field. POST, PUT and PATCH methods are really important, and another publication on this topic will be required, especially for the serialization part.

# PUT Method

> The PUT method requests that the enclosed entity be stored under the supplied Request-URI. If the Request-URI refers to an already existing resource, the enclosed entity SHOULD be considered as a modified version of the one residing on the origin server. If the Request-URI does not point to an existing resource, and that URI is capable of being defined as a new resource by the requesting user agent, the origin server can create the resource with that URI.
>
> -- [RFC2616, section 9.6](https://
www.rfc-editor.org/rfc/rfc2616#section-9.6)

The PUT method is similar to the POST method. Here a `putRequest()` function is created, the content type is updated and the string `test_data` is sent to the server via the [`post()`](https://pub.dev/documentation/dio/latest/dio/Dio/post.html) method.

```dart
Future<int> putRequest() async {
  dio.options.contentType = 'text/plain';
  var response = await dio.put(
    '/',
    data: 'test_data'
  );
  printResponse(response);
  return 0;
}
```

Similar result.

```console
$ dart run bin/httpcat.dart put
{status: 200, status_msg: OK, uri: https://echo.free.beeceptor.com/, headers: connection: close
alt-svc: h3=":443"; ma=2592000
transfer-encoding: chunked
access-control-allow-origin: *
date: Wed, 13 May 2026 14:32:18 GMT
vary: Accept-Encoding
content-type: application/json
via: 1.1 Caddy
, data: {method: PUT, protocol: https, host: echo.free.beeceptor.com, path: /, ip: 1.2.3.4:44886, headers: {Host: echo.free.beeceptor.com, User-Agent: dio, Content-Length: 9, Accept-Encoding: gzip, Content-Type: text/plain, Via: 1.1 Caddy, X-Custom: custom}, parsedQueryParams: {}, rawBody: test_data}}
```

# DELETE Method

> The DELETE method requests that the origin server delete the resource identified by the Request-URI. This method MAY be overridden by human intervention (or other means) on the origin server. The client cannot be guaranteed that the operation has been carried out, even if the status code returned from the origin server indicates that the action has been completed successfully. However, the server SHOULD NOT indicate success unless, at the time the response is given, it intends to delete the resource or move it to an inaccessible location.
>
> -- [RFC2616, section 9.7](https://
www.rfc-editor.org/rfc/rfc2616#section-9.7) 

The DELETE method is closer to the GET method. `deleteRequest()` function is created, and the [`delete()`](https://pub.dev/documentation/dio/latest/dio/Dio/delete.html) method is called.

```dart
Future<int> deleteRequest() async {
  var response = await dio.delete('/');
  printResponse(response);
  return 0;
}
```

Here the returned data:

```console
$ dart run bin/httpcat.dart delete
{status: 200, status_msg: OK, uri: https://echo.free.beeceptor.com/, headers: connection: close
alt-svc: h3=":443"; ma=2592000
transfer-encoding: chunked
access-control-allow-origin: *
date: Wed, 13 May 2026 14:32:49 GMT
vary: Accept-Encoding
content-type: application/json
via: 1.1 Caddy
, data: {method: DELETE, protocol: https, host: echo.free.beeceptor.com, path: /, ip: 1.2.3.4:40520, headers: {Host: echo.free.beeceptor.com, User-Agent: dio, Accept-Encoding: gzip, Via: 1.1 Caddy, X-Custom: custom}, parsedQueryParams: {}}}
```

# PATCH Method

> The PATCH method requests that a set of changes described in the request entity be applied to the resource identified by the Request-URI.  The set of changes is represented in a format called a "patch document" identified by a media type.  If the Request-URI does not point to an existing resource, the server MAY create a new resource, depending on the patch document type (whether it can logically modify a null resource) and permissions, etc.
>
> -- [RFC5789, section 2](https://www.rfc-editor.org/rfc/rfc5789#section-2)

The PATCH method is a recent addition to HTTP, but act similarly like the PUT and POST methods. `patchRequest()` function is created, the content type is updated and  [`patch()`](https://pub.dev/documentation/dio/latest/dio/Dio/patch.html) method is called.

```dart
Future<int> patchRequest() async {
  dio.options.contentType = 'text/plain';
  var response = await dio.patch(
    '/',
    data: 'test_data'
  );
  printResponse(response);
  return 0;
}
```

Again, here the result:

```console
$ dart run bin/httpcat.dart patch
{status: 200, status_msg: OK, uri: https://echo.free.beeceptor.com/, headers: connection: close
alt-svc: h3=":443"; ma=2592000
transfer-encoding: chunked
access-control-allow-origin: *
date: Wed, 13 May 2026 14:33:28 GMT
vary: Accept-Encoding
content-type: application/json
via: 1.1 Caddy
, data: {method: PATCH, protocol: https, host: echo.free.beeceptor.com, path: /, ip: 1.2.3.4:34690, headers: {Host: echo.free.beeceptor.com, User-Agent: dio, Content-Length: 9, Accept-Encoding: gzip, Content-Type: text/plain, Via: 1.1 Caddy, X-Custom: custom}, parsedQueryParams: {}, rawBody: test_data}}
```

# Downloading Files

`dio` is also offering two helpers to download file and store save locally via [`download()`](https://pub.dev/documentation/dio/latest/dio/Dio/download.html) and [`downloadURI()`](https://pub.dev/documentation/dio/latest/dio/Dio/downloadUri.html) methods. Let try to download the latest [official OpenBSD banner](https://www.openbsd.org/images/puffy78.gif) locally using the `downloadUri()` method this time.

```dart
Future<int> downloadRequest() async {
  final url = Uri.parse('https://www.openbsd.org/images/puffy78.gif');
  var response = await dio.downloadUri(
    url,
    (_) => './puffy78.gif',
  );
  printResponse(response);
  return 0;
}
```

`downloadRequest()` function is creating a new [`Uri`](https://api.dart.dev/stable/3.11.5/dart-core/Uri-class.html) object from a valid URL, in this case, from the OpenBSD website. Then, the url and an anonymous function is passed to the `downloadUri()` method. Finally, the response is displayed on STDOUT and the function return `0`.

The anonymous function is taking one argument, a [`Headers`](https://pub.dev/documentation/dio/latest/dio/Headers-class.html) object and must return a `String` representing where the file will be stored.

Let execute that:

```console
$ dart run bin/httpcat.dart download
{status: 200, status_msg: OK, uri: https://www.openbsd.org/images/puffy78.gif, headers: content-type: image/gif
connection: close
last-modified: Wed, 22 Oct 2025 07:18:46 GMT
date: Thu, 14 May 2026 03:50:12 GMT
server: OpenBSD httpd
content-length: 56669
redirects: 0
uri: https://www.openbsd.org/images/puffy78.gif
, data: Instance of 'ResponseBody'}

$ ls -lhart puffy78.gif 
-rw-rw-r-- 1 user user 56K 14 mai   05:50 puffy78.gif
```

It seems the function correctly downloaded the file, and when opening it with `feh`, the gif looks good.

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/x6xpslle1cmj3whae06b.png)

# What about OPTIONS, TRACE and/or custom HTTP Methods?

At this time, OPTIONS and TRACE HTTP methods have not been implemented in `dio`, but it could be possible to craft them using the [`request()`](https://pub.dev/documentation/dio/latest/dio/Dio/request.html) method and setting the [`method`](https://pub.dev/documentation/dio/latest/dio/Options/method.html) attribute from the [`Options`](https://pub.dev/documentation/dio/latest/dio/Options-class.html) class to the correct `String`.

OPTIONS method can be useful when using CORS and then, can be sometime used by developers or administrator to check if everything is right.

> The OPTIONS HTTP method requests permitted communication options for a given URL or server. This can be used to test the allowed HTTP methods for a request, or to determine whether a request would succeed when making a CORS preflighted request.
>
> -- [Mozilla Developer website](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods/OPTIONS)

This time, the [`request()`](https://pub.dev/documentation/dio/latest/dio/Dio/request.html) method can be used. This one permits to modify the [`Options`](https://pub.dev/documentation/dio/latest/dio/Options-class.html) object containing the [`method`](https://pub.dev/documentation/dio/latest/dio/Options/method.html) attribute, defined as String.

Unfortunately, the echo service does not support OPTIONS nor TRACE HTTP method, we will need to use `nc -kl 8080` for this test.

```dart
Future<int> customRequest(String method) async {
  dio.options.method = method;
  var response = await dio.request('http://localhost:8080/');
  printResponse(response);
  return 0;
}
```

We are not really interested of the response here, but more about what the client will send to the server. From the netcat side, here the raw output:

```console
$ nc -kl 8080
OPTIONS / HTTP/1.1
user-agent: dio
connection: close
x-custom: custom
accept-encoding: gzip
content-length: 0
host: localhost:8080
```

The client is correctly using the method we have manually set. The same procedure can also be applied for the TRACE method.

# What about HTTP/2?

[HTTP/2](https://www.rfc-editor.org/rfc/rfc7540) is more a recent protocol upgrading HTTP/1.1 by adding multiplexed connection and use binary format (instead of text) for headers.

> HTTP/2 provides an optimized transport for HTTP semantics.  HTTP/2 supports all of the core features of HTTP/1.1 but aims to be more efficient in several ways. The basic protocol unit in HTTP/2 is a frame (Section 4.1). Each frame type serves a different purpose. [...] Multiplexing of requests is achieved by having each HTTP request/response exchange associated with its own stream. [...] Flow control and prioritization ensure that it is possible to efficiently use multiplexed streams. [...] HTTP/2 adds a new interaction mode whereby a server can push responses to a client. [...] Because HTTP header fields used in a connection can contain large amounts of redundant data, frames that contain them are compressed.
>
> -- [RFC7549, section 2](https://www.rfc-editor.org/rfc/rfc7540#section-2)

What kind of advantage to use HTTP/2 instead of HTTP/1.1? Better performance, especially when it comes to send multiple requests in parallel. Unfortunately, it does not fix everything, like slow connections issues, or a way for the server to easily close a connection, those issues are still relevant with HTTP/2, mainly due to the network layer above it: TCP.

Most - if not all - modern HTTP servers are supporting it ([nginx](https://nginx.org/en/docs/http/ngx_http_v2_module.html), [apache2](https://httpd.apache.org/docs/2.4/howto/http2.html), [cowboy](https://ninenines.eu/docs/en/cowboy/2.14/manual/cowboy_http2/)...) , the same happens for modern clients. `dio` needs the [`http2_adapter`](https://github.com/cfug/dio/tree/main/plugins/http2_adapter) plugin to support this protocol though.

```sh
dart pub add dio_http2_adapter
dart pub get
```

```dart
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
```

```dart
Future<int> http2Request() async {
  dio.httpClientAdapter = Http2Adapter(
    ConnectionManager(idleTimeout: const Duration(seconds: 10)),
  );
  var response = await dio.get('/');
  printResponse(response);
  return 0;
}
```

```console
$ dart run bin/httpcat.dart http2
{status: 200, status_msg: null, uri: https://echo.free.beeceptor.com/, headers: access-control-allow-origin: *
alt-svc: h3=":443"; ma=2592000
content-type: application/json
date: Thu, 14 May 2026 07:52:12 GMT
vary: Accept-Encoding
via: 1.1 Caddy
, data: {method: GET, protocol: https, host: echo.free.beeceptor.com, path: /, ip: 1.2.3.4:34174, headers: {Host: echo.free.beeceptor.com, User-Agent: dio, Via: 2.0 Caddy, X-Custom: custom, Accept-Encoding: gzip}, parsedQueryParams: {}}}
```

I'm not really sure if it correctly using HTTP/2 protocol while using the echo service. Let add a logging feature to see if we can know a bit more there. To do that, we can add a new [`LogInterceptor`](https://pub.dev/documentation/dio/latest/dio/LogInterceptor-class.html) object in the current [interceptor](https://pub.dev/documentation/dio/latest/dio/Interceptor-class.html) queue.

```dart
Future<int> http2Request() async {
  dio.httpClientAdapter = Http2Adapter(
    ConnectionManager(idleTimeout: const Duration(seconds: 10)),
  );
  dio.interceptors.add(
    LogInterceptor(
      logPrint: (o) => print(o.toString()),
      request: true,
      requestBody: true,
      requestHeader: true,
      requestUrl: true,
      responseBody: true,
      responseHeader: true,
      responseUrl: true,
    )
  );
  var response = await dio.get('/');
  printResponse(response);
  return 0;
}
```

Execute the code a second time with the logs now:

```console
$ dart run bin/httpcat.dart http2
*** Request ***
uri: https://echo.free.beeceptor.com/
method: GET
responseType: ResponseType.json
followRedirects: true
persistentConnection: false
connectTimeout: 0:00:05.000000
sendTimeout: null
receiveTimeout: 0:00:05.000000
receiveDataWhenStatusError: true
extra: {}
headers:
 user-agent: dio
 x-custom: custom
data:
null

*** Response ***
uri: https://echo.free.beeceptor.com/
statusCode: 200
headers:
 access-control-allow-origin: *
 alt-svc: h3=":443"; ma=2592000
 content-type: application/json
 date: Thu, 14 May 2026 08:00:36 GMT
 vary: Accept-Encoding
 via: 1.1 Caddy
Response Text:
{"method":"GET","protocol":"https","host":"echo.free.beeceptor.com","path":"/","ip":"1.2.3.4:50442","headers":{"Host":"echo.free.beeceptor.com","User-Agent":"dio","Via":"2.0 Caddy","X-Custom":"custom","Accept-Encoding":"gzip"},"parsedQueryParams":{}}

{status: 200, status_msg: null, uri: https://echo.free.beeceptor.com/, headers: access-control-allow-origin: *
alt-svc: h3=":443"; ma=2592000
content-type: application/json
date: Thu, 14 May 2026 08:00:36 GMT
vary: Accept-Encoding
via: 1.1 Caddy
, data: {method: GET, protocol: https, host: echo.free.beeceptor.com, path: /, ip: 1.2.3.4:50442, headers: {Host: echo.free.beeceptor.com, User-Agent: dio, Via: 2.0 Caddy, X-Custom: custom, Accept-Encoding: gzip}, parsedQueryParams: {}}}
```

Yeah, still not really sure if we are using HTTP/2 there. Let use `netcat` instead, just to be certain.

```console
$ nc -kl | hexdump -C
00000000  50 52 49 20 2a 20 48 54  54 50 2f 32 2e 30 0d 0a  |PRI * HTTP/2.0..|
00000010  0d 0a 53 4d 0d 0a 0d 0a  00 00 06 04 00 00 00 00  |..SM............|
00000020  00 00 02 00 00 00 00 00  00 5b 01 04 00 00 00 01  |.........[......|
00000030  00 07 3a 6d 65 74 68 6f  64 03 47 45 54 00 05 3a  |..:method.GET..:|
00000040  70 61 74 68 01 2f 00 07  3a 73 63 68 65 6d 65 04  |path./..:scheme.|
00000050  68 74 74 70 00 0a 3a 61  75 74 68 6f 72 69 74 79  |http..:authority|
00000060  09 6c 6f 63 61 6c 68 6f  73 74 00 0a 75 73 65 72  |.localhost..user|
00000070  2d 61 67 65 6e 74 03 64  69 6f 00 08 78 2d 63 75  |-agent.dio..x-cu|
00000080  73 74 6f 6d 06 63 75 73  74 6f 6d 00 00 00 00 01  |stom.custom.....|
00000090  00 00 00 01 00 00 04 03  00 00 00 00 01 00 00 00  |................|
```

As you can see, HTTP/2.0 is printed on the netcat side and a part of the data received are in binary format, not text like in HTTP/1.1 version. So, it looks good!

Other examples can be found in `dio_http2_adapter` [`README.md`](https://github.com/cfug/dio/tree/main/plugins/http2_adapter) and in the [`example/`](https://github.com/cfug/dio/blob/main/plugins/http2_adapter/example) directory.

# What about HTTP/3?

> HTTP/3 provides a transport for HTTP semantics using the QUIC transport protocol and an internal framing layer similar to HTTP/2. Once a client knows that an HTTP/3 server exists at a certain endpoint, it opens a QUIC connection. QUIC provides protocol negotiation, stream-based multiplexing, and flow control. Within each stream, the basic unit of HTTP/3 communication is a frame. Each frame type serves a different purpose. Multiplexing of requests is performed using the QUIC stream abstraction. Each request-response pair consumes a single QUIC stream. Streams are independent of each other, so one stream that is blocked or suffers packet loss does not prevent progress on other streams. [...] As in HTTP/2, request and response fields are compressed for transmission.
>
> -- [RFC9114, Section 2](https://datatracker.ietf.org/doc/html/rfc9114#section-2)

Unfortunately, it seems QUIC and HTTP/3 are not currently supported everywhere, it will depend of the platform used. The package [`pure_dart_quic`](https://pub.dev/packages/pure_dart_quic) seems to be the solution here. I don't think the solution was currently very stable, and in fact, the addition of this protocol in nginx for example is from the [1.25.0](https://github.com/nginx/nginx/releases/tag/release-1.25.0) version (released May 2023). The cowboy server is also offering its implementation but not by default since the beginning of 2025 (version [2.13.0](https://ninenines.eu/articles/cowboy-2.13.0/)). So, it will be the main subject for another article, outside of `dio` (or perhaps to extend it).

# Want More About `dio`?

If you are here, that means you enjoyed these notes... And you probably want to know even more about `dio`. Perhaps having a small glimpse of its usage in real world? You can easily find few open source projects using it:

- [**Diohub**](https://github.com/namanshergill/diohub):  open-source unofficial GitHub mobile client

- [**Flutter Crypto APP**](https://github.com/salvadordeveloper/flutter-crypto-app): Complete Flutter Application with Riverpod & Freezed + Dio for API REST.

- [**Vexana**](https://github.com/VB10/vexana): Vexana is easy to use network process with dio. 

- [**randomuser**](https://github.com/jhomlala/randomuser): Example project to present Dio, RxDart and Bloc

- [**Flutter User Management App with Multi-Source Backend Support**](https://github.com/SinaSys/flutter_go_rest_app):  Flutter-based user management application that demonstrates full CRUD (Create, Read, Update, Delete) operations. The app interacts with a RESTful API to manage users and their associated data, including posts, todos, and comments.

- [**youtube_video**](https://github.com/rrifafauzikomara/youtube_video): a Flutter application built to demonstrate the use of Modern development tools with best practices implementation like Clean Architecture, Modularization, Dependency Injection, BLoC, etc.

And to end this section, a list of interesting `dio` plugins:

- [**`dio_file_uploader`**](https://pub.dev/packages/dio_file_uploader): A en_file_uploader plugin to handle the file upload using dio package.

- [**`datadome_flutter_dio`**](https://pub.dev/packages/datadome_flutter_dio):  provides an interceptor that filters and validates all requests to ensure your app networking layer is protected with DataDome.

- [**`dio_builder`**](https://pub.dev/packages/dio_builder): a builder pattern for configuring and creating instances of the Dio HTTP client.

- [**`embrace_dio`**](https://pub.dev/packages/embrace_dio): enable the embrace plugin to capture network requests made with the Dio package.

- [**`alice_dio`**](https://pub.dev/packages/alice_dio): Alice is an HTTP Inspector tool for Flutter which helps debugging http requests.

- [**`dio_http_logger`**](https://pub.dev/packages/dio_http_logger): A powerful network interceptor for Dio, providing comprehensive logging of requests, responses and errors.

- [**`dio_retry_plus`**](https://pub.dev/packages/dio_retry_plus): A plugin for dio that retries failed requests.

- [**`chunked_uploader`**](https://pub.dev/packages/chunked_uploader): A plugin to upload files to server in chunks.

- [**`oauth_dio`**](https://pub.dev/packages/oauth_dio): A customizable oauth client with token storage and interceptors for dio.

- [**`dio_ansi_logger`**](https://pub.dev/packages/dio_ansi_logger): A beautiful, Postman-style Dio interceptor that logs HTTP requests and responses with ANSI colors, structured formatting, and fully customizable themes.

- [**`dio_cache`**](https://github.com/aloisdeniel/dio_cache): A plugin for dio that caches responses in a database for better optimization and offline data access.

- [**`pl_api_helper`**](https://github.com/NexPlugs/pl_api_helper): pl_api_helper is a Flutter plugin that simplifies API calls, caching, and data management with support for both Dio and HTTP clients. 

# References and Resources

- [**dio Package on pub.dev**](https://pub.dev/packages/dio)

- [**dio API Reference**](https://pub.dev/documentation/dio/latest/)

- [**dio Official Repository**](https://github.com/cfug/dio)

- [**Official Flutter Application Example with dio**](http://github.com/cfug/dio/tree/main/example_flutter_app)

- [**Official dio Plugins**](https://github.com/cfug/dio/tree/main/plugins)

- [**Use dio in Flutter/Dart**](https://dev.to/bitecode/use-dio-in-flutter-dart-307o) by @bitecode 

- [**Dio vs HTTP in Flutter: A practical, Clear Comparison**](https://dev.to/heyroziq/dio-vs-http-in-flutter-a-practical-clear-comparison-2id8) by @heyroziq 

- [**Flutter Dio HTTP Client**](https://dev.to/ahmed2hamy/flutter-dio-http-client-5d1d) by @ahmed2hamy 

- [**Flutter dart API REST with Dio**](https://dev.to/stephane_couget_54f540812/flutter-dart-api-rest-with-dio-5784) by @stephane_couget_54f540812 

- [**Efficient CRUD Operations in Flutter: A Guide to Implementing HTTP Requests with Clean Architecture and Dio**](https://dev.to/nikki_eke/efficient-crud-operations-in-flutter-a-guide-to-implementing-http-requests-with-clean-architecture-and-dio-4baj) by @nikki_eke

----

Cover Image by <a href="https://unsplash.com/@ilonaivanova?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Ilona Ivanova</a> on <a href="https://unsplash.com/photos/a-close-up-of-a-bug-p5KVcvZ6XGk?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>