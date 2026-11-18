---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/using-the-http-package-in-dart-5641"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Faqpvtfvefxxs2fnk57ih.jpg"
created_at: "None"
crossposted_at: "None"
description: "The previous publication was talking about the low-level HTTP Client interface HttpClient offered by..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/using-the-http-package-in-dart-5641"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "using-the-http-package-in-dart-5641"
social_image: "None"
title: "Using the http Package in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Using the http Package in Dart

The previous publication was talking about the low-level HTTP Client interface [`HttpClient`](https://api.dart.dev/dart-io/HttpClient-class.html) offered by [`dart:io`](https://api.dart.dev/dart-io). This package does the job, but even the documentation recommends to use [`package:http`](https://pub.dev/packages/http) instead. This is a higher-level implementation dealing with all the portability for different platforms and adding a lot of cool features. Instead of recreating a new project from scratch, we will improve the previous one created: `httpcat`.

First, we need to know how to install a package with Dart. Using an external package requires adding a new dependency in [`pubspec.yaml`](https://dart.dev/tools/pub/pubspec) file present at the root of the project.

```yaml
name: httpcat
description: A sample command-line application.
version: 1.0.0
# repository: https://github.com/my_org/my_repo

environment:
  sdk: ^3.11.5

# Add regular dependencies here.
dependencies:
  path: ^1.9.0
  http: ^1.6.0

dev_dependencies:
  lints: ^6.0.0
  test: ^1.25.
```

The new line added is `http: ^1.6.0` in the `dependencies` section. The command [`dart pub get`](https://dart.dev/tools/pub/cmd/pub-get) needs to be called to fetch the package locally.

 Another method is to use [`dart pub add`](https://dart.dev/tools/pub/cmd/pub-add) subcommand:

```sh
dart pub add http:^1.6.0
```

This command will directly adds the dependency in `pubspec.yaml` without editing with a text editor (and valid it at the same time). Now, we can import this package in our program.

# Importing `http` package

To import a package in Dart, [`import` keyword](https://dart.dev/tools/pub/packages) followed by the package URL is needed. The package can also be locally renamed using `as` keyword followed by the local namespace to use. In our case, importing `http` package will look like that:

```dart
import 'package:http/http.dart' as http;
```

From Dart specification:

> An **import** specifies a library whose exported namespace (or a subset of its mappings) is made available in the current library. An **import** specifies a URI s where the declaration of an imported library is to be found. It is a compile-time error if the specified URI of an import does not refer to a library declaration. The current library is the library currently being compiled. The **import** modifies the **namespace** of the current library in a manner that is determined by the imported library and by the optional elements of the **import**. [...] Imports may be `deferred` or `immediate`. [...] An immediate import directive `I` may optionally include a prefix clause of the form **`as`** `id` used to prefix names imported by `I`. In this case we say that id is an import prefix, or simply a prefix.
> -- [Latest Dart (3.0+) Programming Language Specification Draft](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf) Chapter 19, page 218

# Refactoring `httpcat`

A big part of `httpcat` will be rewritten, even if the logic will stay the same. Let start with `getUrl()`.

```dart
Future<int> getUrl(Uri url) async {
  try {
    var response = await http.get(url);
    print(response.body);
    return 0;
  }
  catch (e) {
    print("outch. something bad happened. $e");
    return 1;
  }
}
```

`getUrl()` function will now accept an already parsed `String` as [`Uri`](https://api.dart.dev/dart-core/Uri-class.html). Indeed, [`http.get()`](https://pub.dev/documentation/http/latest/http/get.html) method is acception `Uri` object as parameter, so, instead of doing all the parsing logic inside the same function, this already parsed string can be passed directly to it. `getUrl()` will also return an `int` based on the result of the http request, in case of success, it will return `0` (zero), in case of failure, it will return `1`. Because this function is asynchronous, the returned value will be wrapped around a [`Future`](https://api.dart.dev/dart-async/Future-class.html).

```dart
Uri? parseUrl(String str) {
  try {
    var url = Uri.parse(str);
    if (url.scheme.isEmpty) url = url.replace(scheme: 'http');
    if (url.host.isEmpty) url = url.replace(host: 'localhost');
    if (url.port == null) url = url.replace(port: 80);
    if (url.path.isEmpty) url = url.replace(path: "/");
    return url;
  }
  catch (e) {
    print("bad url");
    return null;
  }
}
```

`parseUrl()` is a new function in charge of parsing a `String`. In case of success it will return an `Uri` object and in case of failure it will return `null`. We will have a small discussion at the end of this article about [`null` safety](https://dart.dev/null-safety/understanding-null-safety).

```dart
Future<int> main(List<String> arguments) async {
  if (arguments.length != 1) {
    print("Usage: httpcat TARGET");
    return 1;
  }

  Uri? url = parseUrl(arguments[0]);
  if (url == null) return 1;

  var ret = getUrl(url);
  return ret;
}
```

`main()` function - our entry-point - will now be asynchronous because we are returning `getUrl()` value.

The final result can be seen below. Dealing with `null` annoys me a lot, it's a bit like dealing with errors in Go, and I hate that. I suppose [`dartz`](https://pub.dev/packages/dartz/versions) or another package implementing functional programming features could fix that.

```dart
import 'package:httpcat/httpcat.dart' as httpcat;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;

Future<int> main(List<String> arguments) async {
  if (arguments.length != 1) {
    print("Usage: httpcat TARGET");
    return 1;
  }

  Uri? url = parseUrl(arguments[0]);
  if (url == null) return 1;

  var ret = getUrl(url);
  return ret;
}

Uri? parseUrl(String str) {
  try {
    var url = Uri.parse(str);
    if (url.scheme.isEmpty) url = url.replace(scheme: 'http');
    if (url.host.isEmpty) url = url.replace(host: 'localhost');
    if (url.port == null) url = url.replace(port: 80);
    if (url.path.isEmpty) url = url.replace(path: "/");
    return url;
  }
  catch (e) {
    print("bad url");
    return null;
  }
}

Future<int> getUrl(Uri url) async {
  try {
    var response = await http.get(url);
    print(response.body);
    return 0;
  }
  catch (e) {
    print("outch. something bad happened. $e");
    return 1;
  }
}
```

The code is still dirty, but it works. If someone is passing bad URL, it can fail. Let start a small HTTP server using [Python HTTP server module](https://docs.python.org/3/library/http.server.html).

```sh
mkdir /tmp/t
cd /tmp/t
python -m http.server
```

Now, let have some fun with this program.

```console
$ dart run bin/httpcat.dart 'http://localhost:8000'
<!DOCTYPE HTML>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
</ul>
<hr>
</body>
</html>

$ dart run bin/httpcat.dart 'localhost:8080'
outch. something bad happened. Invalid argument(s): Unsupported scheme 'localhost' in URI localhost://localhost/8080
```

As you can see, the first call is returning what we want, the HTML page returned by default by the HTTP server. But when calling it a second time without the scheme defined in the URL, it fails. So, that's a bug we will fix in another iteration.

# Asynchronous call

A quick note on asynchronous programming, more publications will come on this part of Dart, but you can see that part as a kind of reminder. Let start with the - very small - concurrency section from Dart specification.

> Dart code is always single threaded. There is no shared-state concurrency in Dart. Concurrency is supported via actor-like entities called isolates.
> -- [Latest Dart (3.0+) Programming Language Specification Draft](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf) Chapter 6, page 15

The Dart VM is dealing with concurrency via an [event loop](https://dart.dev/language/concurrency#event-loop) on one thread. Applications require to do tasks in parallel though, and then, asynchronous properties. This is where the [`async-await`](https://api.dart.dev/dart-async/) enters the game with the help of [`Futures`](https://api.dart.dev/dart-async/Future-class.html) and [`Streams`](https://api.dart.dev/dart-async/Stream-class.html).

For now, if you want to know more about that, you can check these references:

- [Concurrency in Dart
](https://dart.dev/language/concurrency)

- [Asynchronous programming](https://dart.dev/language/async)

- [Asynchronous programming: futures, async, await](https://dart.dev/libraries/async/async-await)

- [Futures and error handling
](https://dart.dev/libraries/async/futures-error-handling)

# `null` safety

Well. One reason I really love and enjoy coding in Erlang is because of the way it deals with errors and exceptions. A function in Erlang will always returns a values, and those values can be "tagged" with `ok` or `error` or any other term you want. It's not the case by default with Dart and many other "modern" languages. For the ones who don't know Erlang (or Elixir), here an example:

```erlang
my_function() ->
  {ok, "value"}.

callme() ->
  case my_function() of
    {ok, V} ->
      io:format("~p~n", V);
    _ ->
      io:format("nothing~n");
  end.
```

Dealing with `null` in Dart is a long topic, and while trying to find a solution by myself, I was, in fact, recreating a kind of  [Maybe Monad](https://wiki.haskell.org/Maybe). Someone else already this this job with the [`maybe_just_nothing`](https://pub.dev/packages/maybe_just_nothing) package. The idea here is to delegate most of the `null` check to an object, and use functional programming paradigm.

Another solution is to create a solution similar to the one used by Erlang by using [`records`](https://dart.dev/language/records) as a tuple. The tag part can be defined as an [`enum`](https://dart.dev/language/enums).

```dart
enum Tag { ok, error }
```

A function could then [return a record](https://dart.dev/language/records#record-syntax) containing a `Tag` and any kind of data.

```dart
(Tag, String) my_function() {
  return (Tag.ok, "value");
}
```

One can then use some [pattern matching](https://dart.dev/language/patterns) like in Erlang with the help of the [`switch`](https://dart.dev/language/patterns#switch-statements-and-expressions) statement.

```dart
void callme() {
  switch (my_function()) {
    case (Tag.ok, var v):
      print("ok $v");
    default:
      print("error");
  }
}
```

I'm not really sure this is good idea to use this method, if it's portable and how the [`switch`](https://dart.dev/language/branches#switch-expressions) expression can deal with a long list of different patterns (performance issue?).

The Dart documentation offers a great documentation about the null safety issues, and a dev.to author called @jige2025 created two publications ([part-1](https://dev.to/jige2025/dart-lesson-10-null-safety-part-1-why-is-null-safety-needed-5e5g) and [part-2](https://dev.to/jige2025/dart-lesson-11-null-safety-part-2-safe-operators-explained-37l8)) on this topic. Anyway, a full publication will be made to summarize that, so, if you want to know more, please check these references:

- [Understanding null safety
](https://dart.dev/null-safety/understanding-null-safety)

- [Dart Lesson 10: Null Safety (Part 1) — Why is Null Safety Needed?](https://dev.to/jige2025/dart-lesson-10-null-safety-part-1-why-is-null-safety-needed-5e5g)

- [Dart Lesson 11: Null Safety (Part 2) — Safe Operators Explained
](https://dev.to/jige2025/dart-lesson-11-null-safety-part-2-safe-operators-explained-37l8)

- [Null-Aware Elements in Dart 3.8: A Simpler Way to Handle Nulls in Flutter](https://medium.com/@muntasir574/null-aware-elements-in-dart-3-8-a-simpler-way-to-handle-nulls-in-flutter-90feb3851371)

- [Mastering Null Safety in Dart: A Practical Guide for Flutter Developers
](https://dev.to/aashu/mastering-null-safety-in-dart-a-practical-guide-for-flutter-developers-4phh)

----

Cover Image by <a href="https://unsplash.com/@ptrikutam?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Pavan Trikutam</a> on <a href="https://unsplash.com/photos/minimalist-photography-of-three-crank-phones-71CjSSB83Wo?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
      