---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/concurrent-and-parallel-programming-in-dart-with-the-isolate-class-14ej"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fisik1m8xrlnup0q18itg.jpg"
created_at: "None"
crossposted_at: "None"
description: "No one can live entirely on their own, nor can any country or society exist in isolation.  --..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/concurrent-and-parallel-programming-in-dart-with-the-isolate-class-14ej"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "concurrent-and-parallel-programming-in-dart-with-the-isolate-class-14ej"
social_image: "None"
title: "Concurrent and Parallel Programming in Dart with the Isolate class"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Concurrent and Parallel Programming in Dart with the Isolate class

> No one can live entirely on their own, nor can any country or society exist in isolation.
> 
> -- Daisaku Ikeda

Every language is now having its own way to deal with concurrency and parallel programming, in the case of Dart, the designers created `Isolate`s. By default, Dart is running its procedures inside the [main isolate](https://dart.dev/language/concurrency#the-main-isolate), in a single thread, a bit like JavaScript. Using one thread can have drawbacks, especially when the application deals with I/O and high volume of data. If the [`Future`](https://api.dart.dev/dart-async/Future-class.html) and [`Stream`](https://api.dart.dev/dart-async/Stream-class.html) classes don't fix the issues, a developer can spawn another [`Isolate`](https://api.dart.dev/dart-isolate/Isolate-class.html), isolated from the main one, with its own thread. One can imagine this new environment as a totally fresh sandbox... Let see how to play with that.

# Introduction

The next examples present in this article will require [`dart:async`](https://api.dart.dev/dart-async/) and [`dart:isolate`](https://api.dart.dev/dart-isolate/) modules.

```dart
import 'dart:async';
import 'dart:isolate';
```

The Dart code is running by default in the main isolate, like previously said, do we have a way to know on which isolate our code is running? Yes. The [`Isolate.current`](https://api.dart.dev/dart-isolate/Isolate/current.html) property will return an `Isolate` object as a reference to the current [`Isolate`](https://api.dart.dev/dart-isolate/Isolate-class.html). Let creates a new function called `printIsolateInfo()` to see what kind of values have been set on those objects.

```dart
void printIsolateInfo(Isolate isolate) {       
  print({
    'debugName': isolate.debugName,
    'hashCode': isolate.hashCode,
    'runtimeType': isolate.runtimeType,
    'errors': {
      'hashCode': isolate.errors.hashCode,
      'runtimeType': isolate.errors.runtimeType,
      'isBroadcast': isolate.errors.isBroadcast,
    },
    'controlPort': {
      'hashCode': isolate.controlPort.hashCode,
      'runtimeType': isolate.controlPort.runtimeType,
    },
    'pauseCapability': {
      'hashCode': isolate.pauseCapability.hashCode,
      'runTimeType': isolate.pauseCapability.runtimeType,
    },
    'terminateCapability': {
      'hashCode': isolate.pauseCapability.hashCode,
      'runTimeType': isolate.pauseCapability.runtimeType,
    }
  });
}
```

Don't forget to create the entry-point function...

```dart
void main(List<String> arguments) async {
  printIsolateInfo(Isolate.current);
}
```

... And then run the code.

```console
$ dart run
{
  debugName: main,
  hashCode: 366158347,
  runtimeType: Isolate,
  errors: {
    hashCode: 953705591,
    runtimeType: _BroadcastStream<dynamic>,
    isBroadcast: true
  },
  controlPort: {
    hashCode: 1217433094,
    runtimeType: _SendPort},
    pauseCapability: {
      hashCode: -1197642896,
      runTimeType: _Capability
    }, 
  terminateCapability: {
    hashCode: -1197642896,
    runTimeType: _Capability
  }
}
```

As you can see, the [`debugName`](https://api.dart.dev/dart-isolate/Isolate/debugName.html) attribute is containing the string `main`, a direct reference to our main isolate. The unique [`hashCode`](https://api.dart.dev/dart-core/Object/hashCode.html) should always be the same across the code, because it's a reference to the main isolate. The [`errors`](https://api.dart.dev/dart-isolate/Isolate/errors.html) attributes broadcast all `errors` from the isolate via a [`Stream`](https://api.dart.dev/dart-async/Stream-class.html). The [`pauseCapability`](https://api.dart.dev/dart-isolate/Isolate/pauseCapability.html) contains the information about the `pause` capability, a way to pause/resume the execution of an isolate. Finally, the [`terminateCapability`](https://api.dart.dev/dart-isolate/Isolate/terminateCapability.html) is containing the capabilities to use [`kill`](https://api.dart.dev/dart-isolate/Isolate/kill.html) or [`setErrorsFatal`](https://api.dart.dev/dart-isolate/Isolate/setErrorsFatal.html) on the isolate.

Now, let [`spawn`](https://api.dart.dev/dart-isolate/Isolate/spawn.html) a new [`Isolate`](https://api.dart.dev/dart-isolate/Isolate-class.html) and see what this function is printing.

```dart
void main(List<String> arguments) async {
  printIsolateInfo(Isolate.current);
  Isolate.spawn(
    (dynamic msg) {
      printIsolateInfo(Isolate.current);
    },
    'init',
    debugName: 'spawnTest'
  );
}
```

```console
$ dart run
{
  debugName: main,
  hashCode: 17494084,
  runtimeType: Isolate,
  errors: {hashCode: 891951382, runtimeType: _BroadcastStream<dynamic>, isBroadcast: true},
  controlPort: {hashCode: -353652440, runtimeType: _SendPort},
  pauseCapability: {hasCode: -69010913, runTimeType: _Capability},
  terminateCapability: {hasCode: -69010913, runTimeType: _Capability}
}

{
  debugName: spawnTest,
  hashCode: 488819858,
  runtimeType: Isolate,
  errors: {hashCode: 616290898, runtimeType: _BroadcastStream<dynamic>, isBroadcast: true},
  controlPort: {hashCode: 1976022887, runtimeType: _SendPort}, 
  pauseCapability: {hasCode: -259943465, runTimeType: _Capability}, 
  terminateCapability: {hasCode: -259943465, runTimeType: _Capability}
}
```

The `hashCode` and the `debugName` are different. In fact, the content of the `debugName`, if net set, would be `main.<anonymous closure>` with a anonymous function or the name of the function called. What does it mean? Well, the code is executing in a totally different isolate, outside of the main function.

# Spawning an `Isolate`

> An isolated Dart execution context.
>
> -- Dart Language Documentation, [`Isolate` class](https://dart.dev/language/isolates)

The easiest way to spawn an isolate is to use the [`Isolate.run()`](https://api.dart.dev/dart-isolate/Isolate/run.html) static function. When using it, the computation will be done inside an isolate and the value will be returned to the caller.

```dart
void main(List<String> arguments) async {      
  final int result = await Isolate.run(
    () {       
      return List                              
        .generate(100, (i) => i)               
        .reduce((i,acc) => i+acc );            
    }                                          
  );                                           
  print(result);       
}
```

```console
$ dart run
4950
```

The idea behind [`Isolate.run()`](https://api.dart.dev/dart-isolate/Isolate/run.html) is to [hide all the complexity of sharing a `ReceivePort`](https://github.com/dart-lang/sdk/blob/d684a576a6aa954ae107a03b2b4e1d61c3bebe93/sdk/lib/isolate/isolate.dart#L253) on the caller side. Indeed, when an isolate is started, only a `controlPort` (used to send message to the isolate) can be shared with it. To receive message from the spawned isolate, a [`SendPort`](https://api.dart.dev/dart-isolate/SendPort-class.html) should be created and shared with the caller. In fact, this can be seen with the [`Isolate.spawn()`](https://api.dart.dev/dart-isolate/Isolate/spawn.html) function.

```dart
Future<Object?> myRun(Object? Function() compute) {
  ReceivePort retPort = ReceivePort();
  Isolate.spawn(
    (SendPort sendPort) {
      var result = compute();
      sendPort.send(result);
      Isolate.exit();
    },
    retPort.sendPort,
  );
  return retPort.take(1).toList();
}

void main(List<String> arguments) async {
  print(await myRun(() => 1));
}
```

```console
$ dart run
[1]
```

When an [`Isolate`](https://api.dart.dev/dart-isolate/Isolate-class.html) is spawned, the first argument passed can be any kind of data but because an [`Isolate`](https://api.dart.dev/dart-isolate/Isolate-class.html) is... isolated, then a way to send back the result of the computation is required. This is where the [`ReceivePort`](https://api.dart.dev/dart-isolate/ReceivePort-class.html) class is taking place. A [`ReceivePort()`](https://api.dart.dev/dart-isolate/ReceivePort-class.html) object is like a channel, on one side, messages are sent, and messages are received on the other side. When starting our [`Isolate`](https://api.dart.dev/dart-isolate/Isolate-class.html), the only argument passed is [`ReceivePort().sendPort`](https://api.dart.dev/dart-isolate/ReceivePort/sendPort.html), in short, a reference to a [`SendPort()`](https://api.dart.dev/dart-isolate/SendPort-class.html) object, the one side used to send message. This means the newly spawned [`Isolate`](https://api.dart.dev/dart-isolate/Isolate-class.html) can send messages to the main one via this port.

The computation as an anonymous function is then executed, the result sent to the caller via the [`SendPort()`](https://api.dart.dev/dart-isolate/SendPort-class.html) object and the `Isolate` terminated using the [`Isolate.exit()`](https://api.dart.dev/dart-isolate/Isolate/exit.html) method. On the caller side, the [`ReceivePort`](https://api.dart.dev/dart-isolate/ReceivePort-class.html) is acting as a [`Stream`](https://api.dart.dev/dart-async/Stream-class.html) object, only one message is taken via the [`Stream.take()`](https://api.dart.dev/dart-async/Stream/take.html) method and this message is converted to a [`List`](https://api.dart.dev/dart-core/List-class.html), then returned. The official implementation is a bit more complex, it catch the errors and exceptions as well and use a [`Completer`](https://api.dart.dev/dart-async/Completer-class.html) object to deal with the [`Future`](https://api.dart.dev/dart-async/Future-class.html) returned by the [`Isolate`](https://api.dart.dev/dart-isolate/Isolate-class.html).

The last way to spawn an isolate is to use [`Isolate.spawnUri()`](https://api.dart.dev/dart-isolate/Isolate/spawnUri.html). This one is a bit special, because it will call another Dart program inside its own isolate, where the [`uri`](https://api.dart.dev/dart-core/Uri-class.html) parameter is the path to this executable. 

```dart
// bin/i.dart
import 'dart:async';
import 'dart:isolate';
import 'dart:io';

void main(List<String> arguments) async {
  ReceivePort receiver = ReceivePort();
  Isolate.spawnUri(
    Uri.parse('./t.dart'),
    ["this", "is", "a", "test"],
    receiver.sendPort
  );
  await receiver.take(2).listen((message) {
    final hashCode = Isolate.current.hashCode;
    final date = DateTime.now();
    print("received ($hashCode}): ${date} ${message}");
  });
}
```

```dart
// bin/t.dart
import 'dart:isolate';
import 'dart:async';

void main(List<String> arguments, SendPort sender) async {
  sender.send(
    [Isolate.current.hashCode, arguments]
  );
  await Future.delayed(
    Duration(seconds: 1),
    () {
      sender.send([Isolate.current.hashCode, 'delayed!']);
    }
  );
  Isolate.exit();
}
```

```console
$ dart run
received (1058204931}): 2026-07-21 11:16:54.266153 [53502371, [this, is, a, test]]
received (1058204931}): 2026-07-21 11:16:55.277365 [53502371, delayed!]
```




# Stack Memory Isolation Test

> A whole stack of memories never equal one little hope.
>
> -- Charles M. Schulz

Is an isolate's stack isolated from other isolate(s)? That's a good questions in fact, because true isolation also means having its own stack. In case of stack overflow, the isolate crashes without impacting the main isolate. The best way to check that is to create an uncontrolled recursive function (acting as an infinite loop). Dart does not support tail recursive function or other functional method to avoid using the stack when creating a recursive function. In fact, if one wants to use recursive functions in Dart and avoid stack overflows, a trampoline function is required.

```dart
void loop_init(SendPort sender) {
  loop(sender, 0);
}

void loop(SendPort sender, int counter) {
  loop(sender, counter+1);
}

void main(List<String> arguments) async {
  bool breaker = true;
  ReceivePort receiver = ReceivePort();
  ReceivePort error = ReceivePort();
  Isolate.spawn(
    loop_init,
    receiver.sendPort,
    onError: error.sendPort,
    onExit: receiver.sendPort,
  );
  error.listen((x) {
    print(x);
    breaker = false;
  });
  receiver.listen((x) {
    print(x);
  });
  Future.delayed(Duration(seconds: 10), () {
    print("test");
  });
}
```

```console
$ dart run
[Stack Overflow, #0      loop (file:///home/user/tmp/i/bin/i.dart:32:1)
#1      loop (file:///home/user/tmp/i/bin/i.dart:33:3)
...
#16921  loop_init (file:///home/user/tmp/i/bin/i.dart:29:3)
#16922  _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:316:17)
#16923  _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:192:12)
]
null
test
```

It seems the program is still alive, even after a crash on the new isolate via a stack overflow, the main one is still running. 

# Heap Memory Isolation Test

> The life of the dead is placed in the memory of the living.
> 
> -- Marcus Tullius Cicero

An isolate has its own stack, but what about the heap? The stack is limited in size by the system (usually few Megabytes), but the heap is using dynamic allocation by asking memory from the kernel itself (e.g. [`malloc`](https://man.openbsd.org/malloc)). I'm still not really sure how Dart is doing the memory allocation, and in fact, it should probably depend on the final application, a native program will not use the same methods to allocate memory than a program running inside the Dart VM. Anyway, I assume any kind of object creation is created on the heap, so, one object from the main isolate should not be available from another isolate. 

```dart
import 'dart:async';
import 'dart:isolate';
```

The `O` class can be used as a factory when creating it via the `O.create()` function. This class is a simple one, it will only have one private attribute called `_value` as integer, a getter and also a setter.

```dart
class O {
  static O _instance = O();
  int _value;

  O({int value = 0}) : this._value = value;

  int getValue() => _value;
  void setValue(int v) => _value = v;

  factory O.create({int value = 0}) {
    _instance.setValue(value);
    return _instance;
  }
}
```

The main entry-point creates a new `O()` object, and then, will do some operation on it after a delay via the [`Future.delayed()`](https://api.dart.dev/dart-async/Future/Future.delayed.html) function. The same is done inside an Isolate, both are sharing the same object reference.

```dart
void main(List<String> arguments) async {
  var object = O.create(value: 1024);

  Future.delayed(Duration(seconds: 1)).then((_) {
    print('main(hashcode): ${object.hashCode}');
    print('main: ${object.getValue()}');
    object.setValue(2048);
    print('main: ${object.getValue()}');
  });

  Isolate.run(() async {
    await Future.delayed(Duration(seconds: 2)).then((_) {
      print('isolate(hashcode): ${object.hashCode}');
      print('isolate: ${object.getValue()}');
      object.setValue(4096);
      print('isolate: ${object.getValue()}');
    });
  });
}
```

When executed, the `hashCode` of the `O` object is different on the main isolate and the new one. The initialized value (`1024`) can be seen on both output, but if the object was shared across those isolates, the value `2048` would have been printed twice. So, when starting an isolate a part of the heap (or stack?) is being cloned during the initialization phase. 

```console
$ dart run
main(hashcode): 3590485802
main: 1024
main: 2048
isolate(hashcode): 713534114
isolate: 1024
isolate: 4096
```

I'm still not really sure to understand everything, but the native implementation can be found in [`heap.cc` native implementation](https://github.com/dart-lang/sdk/blob/main/runtime/vm/heap/heap.cc)  and [`allocation.cc`](https://github.com/dart-lang/sdk/blob/main/runtime/platform/allocation.cc) (for the stack) from the Dart SDK. It seems the heap is correctly isolated from each isolate.

# Conclusion

Similar features exist on other languages, but the real game changer with the Isolate is the isolation. Indeed, this feature is close to the Actor model, like in Erlang, where a process is spawned and will have its own heap, stack and mailbox. The big difference is the dedicated thread, on the BEAM, the threads are shared. Anyway, using a [`ReceivePort`](https://api.dart.dev/dart-isolate/ReceivePort-class.html) and [`SenderPort`](https://api.dart.dev/dart-isolate/SendPort-class.html) to communicate is also a smart move, similar to the method used to send data to a process via `pipes` on the Unix world, the main drawback is the relative complexity to deal with that.

Isolates are great, and could be a good start for creating autonomous workers or actor model. Luckily, the community is full of packages trying to do that:

- [`actor`](https://pub.dev/packages/actors): actors is a library that enables the use of the Actors Model in Dart;

- [`async_task`](https://pub.dev/packages/async_task): this package brings asynchronous tasks and parallel executors (similar to classic thread pools) for all Dart platforms;

- [`easy_isolate`](https://pub.dev/packages/easy_isolate): an abstraction of isolates providing an easy way to work with different threads;

- [`isolate_manager`](https://pub.dev/packages/isolate_manager): Isolate Manager is a powerful Flutter/Dart package designed to simplify concurrent programming using isolates;

- [`squadron`](https://pub.dev/packages/squadron): multithreading and worker thread pool for Dart / Flutter, to offload CPU-bound and heavy I/O tasks to Isolate or Web Worker threads.

As usual, I am not the only one to write about this topic, and in fact, thanks to all the resources, I was able to understand this concept a bit faster. Here a (long) list of resources.

- [Isolates](https://dart.dev/language/isolates) from the Official Dart Documentation;

- [Concurrency and isolates](https://docs.flutter.dev/perf/isolates) from the Official Dart Documentation;

- [Dart asynchronous programming: Isolates and event loops](https://dart.dev/blog/dart-asynchronous-programming-isolates-and-event-loops) from the Official Dart blog;

- [Better isolate management with Isolate.run()](https://dart.dev/blog/better-isolate-management-with-isolate-run) from the Official Dart blog;

- [Decoding Isolates: Basic to advanced concepts - Part1](https://dev.to/jamescardona11/decoding-isolates-basic-to-advanced-concepts-part1-189k) by @jamescardona11;

- [Dart Isolates Deep Dive — compute, SendPort, and Parallel Processing Patterns](https://dev.to/kanta13jp1/dart-isolates-deep-dive-compute-sendport-and-parallel-processing-patterns-4ij6) by @kanta13jp1;

- [Isolates in Flutter](https://dev.to/mariam_mohmed_fab897cdb28/isolates-in-flutter-2d75) by @mariam_mohmed_fab897cdb28

- [Dart Concurrency Complete Guide — Isolates, compute, Streams, and Mutex Patterns](https://dev.to/kanta13jp1/dart-concurrency-complete-guide-isolates-compute-streams-and-mutex-patterns-2b38) by @kanta13jp1;

- [Dart Concurrency Deep Dive — Isolates, Structured Concurrency, and Async Patterns](https://dev.to/kanta13jp1/dart-concurrency-deep-dive-isolates-structured-concurrency-and-async-patterns-5ala) by @kanta13jp1;

- [Dart Isolates in Depth — Background Processing, Worker Pools, and compute()](https://dev.to/kanta13jp1/dart-isolates-in-depth-background-processing-worker-pools-and-compute-5bgn) by @kanta13jp1;

- [The Practical Hands-On Guide to Flutter Isolates](https://dev.to/utkarsh4517/the-practical-hands-on-guide-to-flutter-isolates-4834) by @utkarsh4517;

- [Effortless Multithreading in Flutter: Mastering Isolates Like a Pro](https://dev.to/michealgabriel/effortless-multithreading-in-flutter-mastering-isolates-like-a-pro-35b7) by @michealgabriel;

- [Flutter Isolates & Compute Complete Guide — Keep Your UI Smooth with Background Processing](https://dev.to/kanta13jp1/flutter-isolates-compute-complete-guide-keep-your-ui-smooth-with-background-processing-455f) by [kanta13jp1](https://dev.to/kanta13jp1)

- [Isolates in Dart & Flutter](https://medium.com/@maulanabima785/isolates-in-dart-flutter-bc3afdcc6cfa) by [Fend](https://medium.com/@maulanabima785) on Medium;

- [A basic introduction to Isolates on Dart.](https://gist.github.com/Starhkz/9a29f511eaeeb1a3c2a0f9efdeba32d3) by [Starhkz](https://gist.github.com/Starhkz/) on Gist;

- [Simple Dart example to demonstrate shared memory for Isolates](https://gist.github.com/xrad/58e426b893f30484769d0c6593eeb7f8) by [xrad](https://gist.github.com/xrad) on Gist;

- [Experimenting on Stream with isolates in flutter](https://gist.github.com/fonkamloic/29523f0eec0a13d978b62a48179056a9) by [fonkamloic](https://gist.github.com/fonkamloic) on Gist;

- [Concurrency in Dart with Isolates and Messages](https://alexanderobregon.substack.com/p/concurrency-in-dart-with-isolates) by [Alexander Obregon](https://substack.com/@alexanderobregon) on Substack;

- [Master Dart Isolate: Unlock Blazing-Fast App Speed](https://dartcounterapp.com/dart-isolate/) by [dieter](https://dartcounterapp.com/author/dietermaes767hotmail-be/) on DartCounterApp;

- [An Introduction to Dart Code and Isolate](https://hackernoon.com/an-introduction-to-dart-code-and-isolate-em3j34u1) form HackerNoon;

- [Dart Isolates and Concurrency Models: Deep Dive into Multi-Threading in Dart 🚀](https://medium.com/@apurba64880/dart-isolates-and-concurrency-models-deep-dive-into-multi-threading-in-dart-2dda1165ba53) by [Apurba](https://medium.com/@apurba64880) on Medium;

- [Deep Dive into Dart’s Memory Allocation Strategies](https://medium.com/@maksymilian.pilzys/deep-dive-into-darts-memory-allocation-strategies-bd1216568403) by [Max Pilzys](https://medium.com/@maksymilian.pilzys) on Medium;

- [Flutter Isolate: Pros, Cons, Limitations, and a Practical Example](https://medium.com/@DeyvissonDev/flutter-isolate-pros-cons-limitations-and-a-practical-example-def5b1778ea9) by [DeyvissonEduardo.Dev](https://medium.com/@DeyvissonDev) on Medium;

- [`isolate.cc` native implementation](https://github.com/dart-lang/sdk/blob/main/runtime/vm/isolate.cc) in C++ from Github.

Happy hack and have fun!

----

Cover Image by <a href="https://unsplash.com/@solimonster?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">sol</a> on <a href="https://unsplash.com/photos/group-of-person-on-stairs-tZw3fcjUIpM?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>