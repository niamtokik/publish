---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/the-stream-class-in-dart-2elb"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Furuvc35f1g3fvocv8l1q.jpg"
created_at: "None"
crossposted_at: "None"
description: "We have seen the Future class in a previous publication, we can now start learning a bit more about..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/the-stream-class-in-dart-2elb"
public_reactions_count: "2"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "the-stream-class-in-dart-2elb"
social_image: "None"
title: "The Stream class in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# The Stream class in Dart

We have seen the `Future` class in a previous publication, we can now start learning a bit more about the `Stream` class. In fact, the `Future.asStream()` method was already there to show a quick example how work a `Stream`.

What a difference with a `Future`? Well, a `Future` is dealing with only one event, a `Stream` deals with a sequence of events. This sequence of events can be created using `yield*`. In this case, the function needs to be marked with `async*`, and will return a `Stream<E>` where `E` is the event type. In short, you can see these objects like an `Iterable` with side effects.

> A source of asynchronous data events.
>
> -- Dart Language Documentation, [`Stream` class](https://api.dart.dev/dart-async/Stream-class.html)

Like for the `Future` class, I will try to take few interesting methods/constructors from the `Stream` class and give some example with use cases.

# Single vs Broadcast Streams

A single-subscription `Stream` is a finite sequence of events, having a beginning and an ending. Only one listener can be configured this kind of objects. For example, you can see that as a file, the content of this file is returned until the end.

> A single-subscription stream allows only a single listener during the whole lifetime of the stream. It doesn't start generating events until it has a listener, and it stops sending events when the listener is unsubscribed, even if the source of events could still provide more. The stream created by an `async*` function is a single-subscription stream, but each call to the function creates a new such stream.
>
> -- [Dart Stream class](https://api.dart.dev/dart-async/Stream-class.html)

A broadcast stream is an infinite sequence of events and can allow many listeners. For example, you can see that as an active connection between a client and a server. The client can send any kind of unpredictable data or events, and the server don't control that, until one part of the connection close the exchange.

> A broadcast stream allows any number of listeners, and it fires its events when they are ready, whether there are listeners or not.
>
> -- [Dart Stream class](https://api.dart.dev/dart-async/Stream-class.html)

Another great definition can be seen in [Using Streams](https://dart.dev/libraries/async/using-streams#two-kinds-of-streams) from the Dart guide.

# `Stream.fromFuture()`

[`Stream.fromFuture()`](https://api.dart.dev/dart-async/Stream/Stream.fromFuture.html) constructor converts a `Future` to a `Stream` object.

```dart
Future<int> t(int x) async {
  print("wait $x seconds");
  await Future.delayed(Duration(seconds: x));
  return x;
}

void main() async { 
  Stream
    .fromFuture(t(1))
    .listen(
      (event) => print("received: $event")
    );
}
```

```console
$ dart run bin/stream_from_future.dart
wait 1 seconds
received: 1
```

Few code examples are using this method, but one can be seen in [`use_trace_precompiler_flag_test.dart`](https://github.com/dart-lang/sdk/blob/4629bff7e99de8bc6ba67b802e24bbaccde40e94/runtime/tests/vm/dart/use_trace_precompiler_flag_test.dart#L93) where a file output is converted to a `Stream`. This method is helpful if one wants to use `Stream` features without modifying deeply an interface using `Future`.

# `Stream.fromFutures()`

[`Stream.fromFutures()`](https://api.dart.dev/dart-async/Stream/Stream.fromFutures.html) constructor converts sequence of `Future` object to a `Stream`.

```dart
Future<int> t(int x) async {
  print("wait $x seconds");
  await Future.delayed(Duration(seconds: x));
  return x;
}

void main() async { 
  Stream
    .fromFutures([
      t(1), 
      t(1), 
      t(2), 
      t(0), 
      t(2)
    ])
    .listen((event) {
      var dt = DateTime.now();
      print("received ($dt): $event");
    });
}
```

```console
$ dart run bin/stream_from_futures.dart
wait 1 seconds
wait 1 seconds
wait 2 seconds
wait 0 seconds
wait 2 seconds
received (2026-05-25 05:58:22.193): 0
received (2026-05-25 05:58:23.877): 1
received (2026-05-25 05:58:23.878): 1
received (2026-05-25 05:58:24.877): 2
received (2026-05-25 05:58:24.878): 2
```

Again, there are not a lot of examples from the SDK source code, and most of them - if not all - are in [`stream_from_futures_test.dart`](https://github.com/dart-lang/sdk/blob/4629bff7e99de8bc6ba67b802e24bbaccde40e94/tests/lib/async/stream_from_futures_test.dart#L134). To me, this method is also a way to reuse some feature without doing deep modification on some interfaces. Can also be quite useful in mocking.

# `Stream.fromIterable()`

[`Stream.fromIterable()`](https://api.dart.dev/dart-async/Stream/Stream.fromIterable.html) constructor creates a `Stream` from an `Iterable` object, it can be a list or any object having the same methods/attributes than an `Iterable` object.

```dart
void main() async {
    Stream
      .fromIterable(
        Iterable.generate(10)
      )
      .listen(print);
}
```

```console
$ dart run bin/stream_from_iterables.dart
0
1
2
3
4
5
6
7
8
9
```

# `Stream.periodic()`

[`Stream.periodic()`](https://api.dart.dev/dart-async/Stream/Stream.periodic.html) constructor creates a `Stream` sending periodically events. Those events are integers, starting from `0` and incremented by `1` for every new "tick".

```dart
void main() async { 
  Stream
    .periodic(Duration(seconds: 1), (count) => count )
    .take(5)
    .forEach(print);
}
```

To avoid having an infinite list of numbers printed on the screen, the `take()` method is used to pick only 5 events and then stop the stream.

```console
$ dart run bin/stream_periodic.dart
0
1
2
3
4
```

Really useful method to create timers for example.

# `Stream.any()`

[`Stream.any()`](https://api.dart.dev/dart-async/Stream/any.html) method returns a boolean based on the content of the `Stream`, if the event one is looking for is present in it, it will return `true` else it will return false.

```dart
void main() async {
  print(await Stream
    .fromIterable([1,2,3,4])
    .any((x) => x >= 2 )
  );
  
  print(await Stream
    .fromIterable([1,2,3,4])
    .any((x) => x > 5 )
  );
}
```

```console
$ dart run bin/stream_any.dart
true
false
```

What kind of use cases... Well, for testing and check if some kind of test cases have returned a specific values, it can be nice. For a real world example, I would probably use it to sanitize some input, but I'm not sure if it's efficient.

# `Stream.asyncMap()`

[`Stream.asyncMap()`](https://api.dart.dev/dart-async/Stream/asyncMap.html) method acts like classic `map()` except the function applied can be asynchronous.

```dart
Future<int> t(int s) async {
  await Future.delayed(Duration(seconds: s));
  return s;
}

void main() async {
  Stream
    .fromFutures([t(1), t(0), t(2)])
    .asyncMap((x) => x + 1)
    .listen((x) => print(x));
}
```

```console
$ dart run bin/stream_async_map.dart
1
2
3
```

# `Stream.contains()`

[`Stream.contains()`](https://api.dart.dev/dart-async/Stream/contains.html) method returns `true` if an event is equal to the value given to `contains()`, else it returns `false`.

```dart
Future<int> t(int x) async {
  print("wait $x seconds");
  await Future.delayed(Duration(seconds: x));
  return x;
}

void main() async { 
   print(
    Stream
      .fromFutures([
        t(1), t(2), t(3)
      ])
      .contains(1)
  );
  
  print(
    await Stream
      .fromFutures([
        t(1), t(2), t(3)
      ])
      .contains(1)
  );
  
  print(
    await Stream
      .fromFutures([
        t(1), t(2), t(3)
      ])
      .contains(0)
  );
}
```

```console
$ dart run bin/stream_contains.dart
wait 1 seconds
wait 2 seconds
wait 3 seconds
Instance of '_Future<bool>'
wait 1 seconds
wait 2 seconds
wait 3 seconds
true
wait 1 seconds
wait 2 seconds
wait 3 seconds
false
```

# `Stream.drain()`

[`Stream.drain()`](https://api.dart.dev/dart-async/Stream/drain.html) method discards all event from a stream and replace it with a specific value.

```dart
void main() async { 
  final s = await Stream.fromIterable([1,2,3,4,5]);
  print(await s.isEmpty);
  print(await s.length);
  
  await s.drain([]);
  print(await s.isEmpty);
  print(await s.length);
  
  final s2 = await s.drain([]);
  print(s2.isEmpty);
  print(s2.length);
}
```

```console
$ dart run bin/stream_drain.dart
false
5
true
0
```

I'm still not really sure how this method is working. I thought calling it on the first instance would discard all events, but it was not the case, a copy of the first instance was necessary. So, I assume a stream can only be drained while it is instantiated.

# `Stream.every()`

[`Stream.every()`](https://api.dart.dev/dart-async/Stream/every.html) method is similar to `Stream.any()`.

```dart
void main() async { 
  print(
    await Stream
      .fromIterable([1,2,3,4,5])
      .every((x) => x <= 1)
  );
  
  print(
    await Stream
      .fromIterable([1,2,3,4,5])
      .every((x) => x > 0)
  );
}
```

```console
$ dart run bin/stream_every.dart
false
true
```

# `Stream.fold()`

[`Stream.fold()`](https://api.dart.dev/dart-async/Stream/fold.html) method

```dart
void main() async { 
  print(
    await Stream
      .fromIterable([1,2,3,4,5])
      .fold<int>(0, (acc, element) => acc + element)
  );
  
  print(
    await Stream
      .fromIterable([1,2,3,4,5])
      .fold<int>(1, (acc, element) => acc * element)
  );
  
  print(
    await Stream
      .fromIterable(Iterable.generate(5))
      .map((x) => x + 65)
      .map((x) => String.fromCharCode(x))
      .fold<String>("", (acc, element) => acc + element)
  );
}
```

The casting with the returned type is important there, because a `Stream` can return `null`, then, the `fold()` method must define the type of data returned.

```console
$ dart run bin/stream_fold.dart
15
120
ABCDE
```

# `Stream.forEach()`

[`Stream.forEach()`](https://api.dart.dev/dart-async/Stream/forEach.html) method execute a function on each element of the stream, it returns only a `Future<void>` when it's done.

```dart
void main() async {
    Stream
      .fromIterable([1,2,3,4,5])
      .forEach((x) => print(x)); 
}
```

```console
$ dart run bin/stream_foreach.dart
1
2
3
4
5
```

# `Stream.listen()`

[`Stream.listen()`](https://api.dart.dev/dart-async/Stream/listen.html) method listens for an event and applies a function on it. It can also deal with errors (`onError`) and the last event of the stream (`onDone`).

```dart
Future<int> t(int x) async {
  if (x>4) throw("error");
  return x;
}

void main() async {
    Stream
      .fromFutures(
        [t(1), t(2), t(3), t(4), t(5)]
      )
      .listen(
        (x) {
          print(x);
        },
        onError: (x) {
          print(x);
        },
        onDone: () {
          print("done");
        },
        cancelOnError: false
      ); 
}
```

```console
$ dart run bin/stream_listen.dart
1
2
3
4
error
done
```

# `Stream.map()`

[`Stream.map()`](https://api.dart.dev/dart-async/Stream/map.html) method applies a function to the events from the Stream. Similar to `Iterable.map()`.

```dart
void main() async {
    Stream
      .fromIterable([1,2,3,4,5])
      .map((x) => x + 1)
      .listen(print);
}
```

```console
$ dart run bin/stream_map.dart
2
3
4
5
6
```

# `Stream.pipe()`

[`Stream.pipe()`](https://api.dart.dev/dart-async/Stream/pipe.html) method gives a way to pipe the streams into a stream consumer object. To do that, one must implement a new class using the `StreamConsumer` abstract class. A good use case can be found in [tests/lib/async/slow_consumer_test.dart](https://github.com/dart-lang/sdk/blob/main/tests/lib/async/slow_consumer_test.dart).

```dart
import 'dart:async';

class SC implements StreamConsumer<int> {
  int _counter = 0;
  num _sum = 0;
  
  SC();
  
  Future addStream(Stream s) async {
    print("add stream $s");
    await s.forEach((x) => _sum += x);
    _counter += 1;
    return s;
  }
  
  Future close() {
    print("close (sum: $_sum)");
    return new Future.value(_counter);
  }
}

void main() async {
    await Stream
      .fromIterable([1,2,3,4,5])
      .pipe(new SC())
      .then((x) => print("then: $x"));
}
```

```console
add stream Instance of '_MultiStream<int>'
close (sum: 15)
then: 1
```

Adding a consumer in a pipe with a custom state can be helpful for many things, the use case presented in the test suite to control the data consumption speed is one of them, but we can eventually also use it to collect stats or filter different kind of requests. More examples can be found in the SDK source code, involving `dart:io` package and dealing with sockets and files.

# `Stream.reduce()`

[`Stream.reduce()`](https://api.dart.dev/dart-async/Stream/reduce.html) method is similar to `fold()` except it does not have any initial values.

```dart
void main() async { 
  print(
    await Stream
      .fromIterable([1,2,3,4,5])
      .reduce((acc, element) => acc + element)
  );
  
  print(
    await Stream
      .fromIterable([1,2,3,4,5])
      .reduce((acc, element) => acc * element)
  );
  
  print(
    await Stream
      .fromIterable(Iterable.generate(5))
      .map((x) => x + 65)
      .map((x) => String.fromCharCode(x))
      .reduce((acc, element) => acc + element)
  );
}
```

```console
$ dart run bin/stream_reduce.dart
15
120
ABCDE
```

# `Stream.take()`

[`Stream.take()`](https://api.dart.dev/dart-async/Stream/take.html) method takes only a specific amount of events from the `Stream`.

```dart
Future<int> t(int x) async {
  if (x>4) throw("error");
  return x;
}

void main() async {
    Stream
      .fromFutures(
        [t(1), t(2), t(3), t(4), t(5)]
      )
      .take(3)
      .listen(print);
}
```

```console
$ dart run bin/dart_take.dart
1
2
3
```

# `Stream.transform()`

[`Stream.transform()`](https://api.dart.dev/dart-async/Stream/transform.html) method applies a [`StreamTransformer`](https://api.dart.dev/dart-async/StreamTransformer-class.html) to the `Stream`.

```dart
import 'dart:async';

void main() async {
    Stream
      .periodic(Duration(seconds: 1), (x) => x)
      .take(5)
      .transform(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) {
            print("transform: $data");
            sink.add(data+1);
          },
          handleError: (error, stacktrace, sink) {
            sink.add("transform: error $error");
          },
          handleDone: (sink) {
            print("transform: done");
            sink.add("done");
          }
        ),
      )
      .listen((x) => print("listen $x"));
}
```

At first, I wanted to create my own class implemented using [`StreamTransformer`](https://api.dart.dev/dart-async/StreamTransformer-class.html) but for some kind of reason, it was failing. So, instead, I'm using [`StreamTransformer.fromHandlers()`](https://api.dart.dev/dart-async/StreamTransformer/StreamTransformer.fromHandlers.html) method which returns a valid `StreamTransformer` object that can be used with [`Stream.transform()`](https://api.dart.dev/dart-async/Stream/transform.html) method.

```console
$ dart run bin/stream_transform.dart
transform: 0
listen 1
transform: 1
listen 2
transform: 2
listen 3
transform: 3
listen 4
transform: 4
listen 5
transform: done
listen done
```

To be honest, this method was not so easy to understand on my side. I've read lot of code example to have an idea how to use it "correctly" (and I still have a doubt). Here where one can find some example from Dart SDK:

- [`stream_distinct_test.dart`](https://github.com/dart-lang/sdk/blob/4629bff7e99de8bc6ba67b802e24bbaccde40e94/tests/lib/async/stream_distinct_test.dart#L140)

- [`basic_test.dart`](https://github.com/dart-lang/sdk/blob/4629bff7e99de8bc6ba67b802e24bbaccde40e94/tests/language/async_star/basic_test.dart#L17)

- [`stream_transform_test.dart`](https://github.com/dart-lang/sdk/blob/4629bff7e99de8bc6ba67b802e24bbaccde40e94/tests/lib/async/stream_transform_test.dart#L62)

- [`stream_transformer_from_bind_test.dart`](https://github.com/dart-lang/sdk/blob/4629bff7e99de8bc6ba67b802e24bbaccde40e94/tests/lib/async/stream_transformer_from_bind_test.dart#L14)

- [`stream_transformer_test.dart`](https://github.com/dart-lang/sdk/blob/4629bff7e99de8bc6ba67b802e24bbaccde40e94/tests/lib/async/stream_transformer_test.dart#L43)

- [`stream_transformation_broadcast_test.dart`](https://github.com/dart-lang/sdk/blob/4629bff7e99de8bc6ba67b802e24bbaccde40e94/tests/lib/async/stream_transformation_broadcast_test.dart#L101)

- [`stream_event_transformed_test.dart`](https://github.com/dart-lang/sdk/blob/4629bff7e99de8bc6ba67b802e24bbaccde40e94/tests/lib/async/stream_event_transformed_test.dart#L74)

# Last Words

The `Stream` class is almost as critical than the `Future` one. Dealing with a sequence of events is an important task in any modern programming language. This publication will probably be not the last one on `Stream` and `Future` classes, because there are more to learn, like `Completer`, `StreamConsumer`, `StreamController`, `StreamIterator`, `StreamSink`, `StreamTransformer classes and many others... Another publications will also be necessary to give real world examples using real data.

Anyway, as usual, if the previous examples and use cases presented in this post were not enough, here a list of interesting links to check:

- [Asynchronous Programming: Streams](https://dart.dev/libraries/async/using-streams) from the official Dart guide, a very great introduction to `Future`, `Stream` and asynchronous programming;

- [Creating streams in Dart](https://dart.dev/libraries/async/creating-streams) from the official Dart guide, it explains how to create stream with real world examples;

- [Stream class implementation](https://github.com/dart-lang/sdk/blob/main/sdk/lib/async/stream.dart) source code from Official Dart SDK repository, where one can read the full implementation;

- [Stream test suite](https://github.com/dart-lang/sdk/blob/main/tests/lib/async), source code directory, check all files prefixed by `stream*`, where the test cases are defined, it can be a good place for more examples and use cases;

- [Dart asynchronous programming: Streams](https://medium.com/dartlang/dart-asynchronous-programming-streams-2569a993324d) by [Kathy Walrath](https://medium.com/@kathyw_39223) on Medium

- [Streams in Dart](https://dev.to/lionnelt/streams-in-dart-21le) by @lionnelt

- [Understanding Streams in Flutter (Dart)](https://medium.com/flutter-community/understanding-streams-in-flutter-dart-827340437da6) by [Nitish Kumar Singh](https://medium.com/@nitishk72) on Medium

- [How to use Streams in Dart (Part 1)](https://dev.to/creativ_bracket/how-to-use-streams-in-dart-part-1-25ie) by @creativ_bracket

- [Working with Streams in Dart: Using Stream and StreamController to Handle Asynchronous Data](https://gzeloni.medium.com/working-with-streams-in-dart-using-stream-and-streamcontroller-to-handle-asynchronous-data-ff3250bb80f7) by [Gustavo Zeloni](https://gzeloni.medium.com/) on Medium

- [How to Transform Dart Streams: A Basic Guide to Stream Operators](medium.com/canopas/how-to-transform-dart-streams-a-basic-guide-to-stream-operators-c33f17c1aaf9) by [Sneha S](https://medium.com/canopas/how-to-transform-dart-streams-a-basic-guide-to-stream-operators-c33f17c1aaf9) on Medium

----

Cover Image by <a href="https://unsplash.com/@qixna?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Felix yu</a> on <a href="https://unsplash.com/photos/water-falls-in-brown-wooden-surface-irMcYlCpeTI?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>