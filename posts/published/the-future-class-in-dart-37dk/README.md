---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/the-future-class-in-dart-37dk"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fs4u4eewv0k8dpy4v3vy7.jpg"
created_at: "None"
crossposted_at: "None"
description: "The Future class is the main abstraction to deal with concurrency and asynchronous programming in..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/the-future-class-in-dart-37dk"
public_reactions_count: "2"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "the-future-class-in-dart-37dk"
social_image: "None"
title: "The Future class in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# The Future class in Dart


The [`Future` class](https://api.dart.dev/dart-async/Future-class.html) is the main abstraction to deal with concurrency and asynchronous programming in Dart. The goal of this class is to create an asynchronous computation and deal with its return, even if it's an error or an exception.

> The result of an asynchronous computation.
>
> -- Dart Language Documentation, [`Future` class](https://api.dart.dev/dart-async/Future-class.html)

A lot of attributes, methods and functions can be used with this class of objects, the following sections will be the ones I think they will be the most useful to me.

# `Future.delayed()`

The [`Future.delayed()`](https://api.dart.dev/dart-async/Future/Future.delayed.html) constructor create a new `Future` executed after a defined delay. The following code will print the date after 10 seconds. It can also be used to create asynchronous sleep function. Indeed, the [`sleep()`](https://api.dart.dev/dart-io/sleep.html) function defined in [`dart:io`](https://api.dart.dev/dart-io) block the whole event loop.

```dart
void main() async {
  print("sync: ${DateTime.now()}");
  
  Future.delayed(Duration(seconds: 3), () {
    print("async: ${DateTime.now()}");
  });
  print("sync: ${DateTime.now()}");
  
  await Future.delayed(Duration(seconds: 3), () {
    print("async: ${DateTime.now()}");
  });
  print("sync: ${DateTime.now()}");
}
```

```console
$ bin/delayed.dart
sync: 2026-05-24 07:02:29.298
sync: 2026-05-24 07:02:29.299
async: 2026-05-24 07:02:33.131
async: 2026-05-24 07:02:33.132
sync: 2026-05-24 07:02:33.132
```

What kind of use case? Well, I think one of the first we can think is to create an asynchronous [`sleep()`](https://api.dart.dev/dart-io/sleep.html) function. Indeed, the one provided by `dart:io` package blocks the whole Dart event loop and can make things a bit complicated. Here a quick and dirty implementation of the asynchronous version:

```dart
/// An asynchronous sleep function using
/// Future.delayed(), can be used without
/// blocking the whole event loop thread.
Future<int> sleep(int s) async {
  return new Future.delayed(Duration(seconds: s), () => s);
}
```

Any delayed execution of function with side effect can be a good use case, like retrieving data from the web for example.


# `Future.microtask()`

The [`Future.microtask()`](https://api.dart.dev/dart-async/Future/Future.microtask.html) constructor schedule a computation as a micro task. The idea here is to ensure the returned value of the function from the microtask will be returned before any other asynchronous task. 

```dart
void main() async {  
  Future.new(() {
    print("async: ${DateTime.now()}");
  });  
  
  Future.microtask(() => print("microtask: test"));
  Future.microtask(() => print("microtask: test2"));
  Future.microtask(() => print("microtask: test3"));

  await Future.delayed(Duration(seconds: 3), () {
    print("async: ${DateTime.now()}");
  });
}
```

```console
$ bin/microtask.dart
microtask: test
microtask: test2
microtask: test3
async: 2026-05-24 07:10:11.098
async: 2026-05-24 07:10:14.131
```

Right now, I don't have any real use case in mind, but, it could probably be used when some kind of data are required before any other (e.g. credentials).

# `Future.value()`

The [`Future.value()`](https://api.dart.dev/dart-async/Future/Future.value.html) constructor returns a `Future` with the value passed as argument.

```dart
void main() async {  
  print(Future.value(10));
  print(await Future.value(11));
}
```

```console
$ bin/value.dart
Instance of '_Future<int>'
11
```

Again, I'm not really sure how to use this one correctly, and in which scenario it could be useful. I'm assuming it can be needed for testing purpose, especially for mocking stuff.

# `Future.asStream()`

The [`Future.asStream()`](https://api.dart.dev/dart-async/Future/asStream.html) method convert a `Future` to a `Stream` containing only one element.

```dart
void main() async {  
  Future.value(10)
    .asStream()
    .listen((x) => print(x));
}
```

```console
$ dart run bin/as_stream.dart
10
```

I have few use case in mind. Firstly, when you don't want to change an interface already using a `Stream` and you have to use a `Future` somewhere. The other scenario is for testing purpose, especially for mocking.

# `Future.catchError()`

The [`Future.catchError()`](https://api.dart.dev/dart-async/Future/catchError.html) method is used to `catch` errors during the execution of the `Future`; it acts like a [`try`/`catch`](https://dart.dev/language/error-handling#catch) clause.

```dart
Future<int> t(int x) async {
  if (x<7) return x;
  throw("error");
}

void main() async { 
  for (var i in Iterable.generate(10)) {
    var ret = await t(i)
      .catchError(
        // must reture a Future<int> to catch the error
        // correctly
        (err) async {
          print(err);
          return -1;
        }, 
        test: (_) => true
      )
      print(ret);
    }
}
```

The value returned by the `catchError()` anonymous function must have the same type than the one returned by the `Future`. If the future returns a `Future<int>` then the function defined in the `catchError()` method must also returns a `Future<int>`. Not respecting this rule will raise an exception.

```console
$ dart run bin/catch_error.dart
0
1
2
3
4
5
6
error
-1
error
-1
error
-1
```

Many use case there, this is in fact, probably a fundamental method to use in any software. Instead of using a `try`/`catch`, using a "pipeline" to catch it is more elegant.

# `Future.then()`

The [`Future.then()`](https://api.dart.dev/dart-async/Future/then.html) method returns and alter the value returned by the `Future`.

```dart
Future<int> t(int x) async {
  return x;
}

void main() async { 
  for (var i in Iterable.generate(10)) {
    var f = await 
      t(i)
      .then((x) => x+1);
    print("i=${i}: f=${f}");
  }
}
```

```console
$ dart run bin/then.dart
i=0: f=1
i=1: f=2
i=2: f=3
i=3: f=4
i=4: f=5
i=5: f=6
i=6: f=7
i=7: f=8
i=8: f=9
i=9: f=10
```

Again, this method seems to be quite important and fundamental. It can be used for example to modify the returned value of some specific function, useful in real world application when an application is updated, but we don't want to change the whole interface. It can also be useful in testing context.

# `Future.onError()`

The [`Future.onError()`](https://api.dart.dev/dart-async/FutureExtensions/onError.html) method is quite similar than the `catchError()` seen previously, but permitting a fine grained error handling.

```dart
Future<int> t(int x) async {
  if (x%2 != 0) return x;
  throw("error");
}

void main() async { 
  for (var i in Iterable.generate(2)) {
    var f = await 
      t(i)
      .onError(
        (err, trace) {
          print("$err, $trace");
          return -1;
        },
        test: (_) => true
      );
    print("i=${i}: f=${f}");
  }
}
```

The stack trace can also be available on the `catchError()` method.

```console
$ dart run bin/on_error.dart
error, Error
    at Object.throw_ [as throw] (https://stable.api.dartpad.dev/artifacts/dart_sdk_new.js:3803:11)
    at blob:null/f8144f6a-c3bf-4e21-9dbc-0c8ed71a4da1:110:23
    at https://stable.api.dartpad.dev/artifacts/dart_sdk_new.js:40935:13
    at https://stable.api.dartpad.dev/artifacts/dart_sdk_new.js:40945:7
    at Object._asyncStartSync (https://stable.api.dartpad.dev/artifacts/dart_sdk_new.js:40893:5)
    at Object.t (blob:null/f8144f6a-c3bf-4e21-9dbc-0c8ed71a4da1:116:18)
    at blob:null/f8144f6a-c3bf-4e21-9dbc-0c8ed71a4da1:140:154
    at https://stable.api.dartpad.dev/artifacts/dart_sdk_new.js:40935:13
    at https://stable.api.dartpad.dev/artifacts/dart_sdk_new.js:40945:7
    at Object._asyncStartSync (https://stable.api.dartpad.dev/artifacts/dart_sdk_new.js:40893:5)
    at Proxy.main$ (blob:null/f8144f6a-c3bf-4e21-9dbc-0c8ed71a4da1:164:18)
    at Object.main$ [as main] (blob:null/f8144f6a-c3bf-4e21-9dbc-0c8ed71a4da1:53:10)
    at runMainAndHandleErrors (https://stable.api.dartpad.dev/artifacts/ddc_module_loader.js:1557:45)
    at LibraryManager._runMain (https://stable.api.dartpad.dev/artifacts/ddc_module_loader.js:1579:9)
    at LibraryManager.runMain (https://stable.api.dartpad.dev/artifacts/ddc_module_loader.js:1593:12)
    at DartDevEmbedder.runMain (https://stable.api.dartpad.dev/artifacts/ddc_module_loader.js:2140:22)
    at contextLoaded (blob:null/f8144f6a-c3bf-4e21-9dbc-0c8ed71a4da1:181:19)
    at Object.execCb (https://dartpad.dev/require.js:8:16727)
    at e.check (https://dartpad.dev/require.js:8:10499)
    at e.<anonymous> (https://dartpad.dev/require.js:8:12915)
    at https://dartpad.dev/require.js:8:1542
    at https://dartpad.dev/require.js:8:13376
    at each (https://dartpad.dev/require.js:8:1020)
    at e.emit (https://dartpad.dev/require.js:8:13344)
    at e.check (https://dartpad.dev/require.js:8:11058)
    at e.enable (https://dartpad.dev/require.js:8:13242)
    at e.init (https://dartpad.dev/require.js:8:9605)
    at a (https://dartpad.dev/require.js:8:8305)
    at Object.completeLoad (https://dartpad.dev/require.js:8:16151)
    at HTMLScriptElement.onScriptLoad (https://dartpad.dev/require.js:8:16882)
i=0: f=-1
i=1: f=1
```

Same use case than `catchError()` method, but it could be used when one requires a fine grained exception handler.

# `Future.timeout()`

The [`Future.timeout()`](https://api.dart.dev/dart-async/Future/timeout.html) method ensure the future will be executed in a specific amount of time.

```dart
Future<int> t(int x) async {
  await Future.delayed(Duration(seconds: x));
  return x;
}

void main() async { 
  for (var i in Iterable.generate(5)) {
    print(i);
    var f = await 
     t(i)
     .timeout(Duration(seconds: 2),
             onTimeout: () {
               print("timeout");
               return -1;
             });
    print("i=${i}: f=${f}");
  }
}
```

```console
$ dart run bin/timeout.dart
0
i=0: f=0
1
i=1: f=1
2
i=2: f=2
3
timeout
i=3: f=-1
4
timeout
i=4: f=-1
```

This method seems to be also fundamental, especially when dealing with remote API, or dealing with huge data. Indeed, not everyone got a great internet connection, and the delay to retrieve some information can take a while. In this situation, a timeout must be configured to avoid wasting too much time fetching data you will probably never have. Especially helpful in synchronous call with side effects.

# `Future.whenComplete()`

The [`Future.whenComplete()`](https://api.dart.dev/dart-async/Future/whenComplete.html) method is equivalent to the [`finally`](https://dart.dev/language/error-handling#finally) clause.

```dart
Future<int> t(int x) async {
  print("wait $x seconds");
  await Future.delayed(Duration(seconds: x));
  return x;
}

void main() async { 
  await t(10)
    .timeout(Duration(seconds: 1), 
     onTimeout: () {
       print("timeout...");
       return -1;
    })
    .whenComplete(() {
      print("close actions");
    });
}
```

```console
$ dart run bin/when_complete.dart
wait 10 seconds
timeout...
close actions
```

If one needs to deal with some last actions to execute anytime, even after a failure, this method seems the best to use. It can be used to explicitly close a connection or close a file descriptor.

# Last Words

The `Future` class is a critical part of any Dart application. The previous examples are only a small glimpse of what can be done with it, and if one wants to know more about them, I highly recommend the following links:

- [Future class implementation](https://github.com/dart-lang/sdk/blob/main/sdk/lib/async/future.dart) source code from the Official Dart SDK repository, where you will find the implementation of the class itself;

- [Future Test Suite](https://github.com/dart-lang/sdk/blob/main/tests/lib/async) source code directory, check all files prefixed by `future*`, where you will find all test cases, useful to have real world example.

The next publication will be on the `Stream` class, another important part of Dart ecosystem.

----

Cover Image by <a href="https://unsplash.com/@chrisliverani?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Chris Liverani</a> on <a href="https://unsplash.com/photos/two-person-shaking-hands-near-white-painted-wall-9cd8qOgeNIY?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>