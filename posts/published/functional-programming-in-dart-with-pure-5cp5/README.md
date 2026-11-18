---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/functional-programming-in-dart-with-pure-5cp5"
comments_count: "2"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fndhgmgbfmu56t0pdtece.jpg"
created_at: "None"
crossposted_at: "None"
description: "Writing only functional oriented code can become addictive and when switching to something different,..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/functional-programming-in-dart-with-pure-5cp5"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "functional-programming-in-dart-with-pure-5cp5"
social_image: "None"
title: "Functional Programming in Dart with pure"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Functional Programming in Dart with pure

Writing only functional oriented code can become addictive and when switching to something different, like OOP, it's kinda hard to forgot about all these marvelous techniques previously learned. Luckily, many packages can be found to fix this issue on Dart, the oldest one is called [`dartz`](https://pub.dev/packages/dartz) and was created by [**Björn Sperber**](https://github.com/spebbe). Bad luck though, the [project repository](https://github.com/spebbe/dartz) seems to be unmaintained. If you are still curious, one interesting talk ([Pure functional programming in Dart](https://www.youtube.com/watch?v=90jq6HAb2gw) by Björn Sperber) can be found on youtube.

Few other projects exist into the wild to implement functional programming in Dart. Here a quick summary list:

- [`dartz`](https://pub.dev/packages/dartz), the latest version is `0.10.1`, but the project is inactive. This was one of the first Dart module implementing functional programming concept, perhaps also the first one to be presented during a conference;

- [`pure`](https://pub.dev/packages/pure), the latestversion at this time of writing is `1.0.0`. The project is active and quite minimalist;

- [`fpdart`](https://pub.dev/packages/fpdart), the latest version is `1.2.0`, and the project seems to be active;

- [`dfunc`](https://pub.dev/packages/dfunc), the latest version is `0.10.0` but the project seems to be stopped.

- [`ribs_core`](https://pub.dev/packages/ribs_core), the latest version is `1.0.0` and the project seems to be active and maintained. The [functional interfaces](https://cranst0n.github.io/ribs/api/package-ribs_core_ribs_core/) look great! Thanks to @randalschwartz. 

The choice of a package is limited, only `pure` and `fpdart` seem to be active. I'm a bit sad, I wanted to test `dartz` but if it's a dead project, it's better to move to something else. In this article, we will focus on the [`pure`](https://pub.dev/packages/pure) package.

# Bootstrapping

[`pure`](https://pub.dev/packages/pure) project includes [API documentation](https://pub.dev/documentation/pure/latest/) and [few examples](https://github.com/purplenoodlesoop/pure/tree/master/example). The source code is also available on [Github](https://github.com/purplenoodlesoop/pure). 

```console
$ dart create tpure
Creating tpure using template console...

  .gitignore
  analysis_options.yaml
  CHANGELOG.md
  pubspec.yaml
  README.md
  bin/tpure.dart
  lib/tpure.dart
  test/tpure_test.dart

Running pub get...                     0.3s
  Resolving dependencies...
  Downloading packages...
  Changed 48 dependencies!
  1 package has newer versions incompatible with dependency constraints.
  Try `dart pub outdated` for more information.

Created project tpure in tpure! In order to get started, run the following commands:

  cd tpure
  dart run

$ cd tpure

$ dart pub add pure
Resolving dependencies... 
Downloading packages... 
  package_config 2.2.0 (3.0.0 available)
+ pure 1.0.0
Changed 1 dependency!
1 package has newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more inf
```

`pure` is using [Dart extension types](https://dart.dev/language/extension-types) feature to create wrappers around types.

```dart
import 'package:pure/pure.dart';
```

# Constant

> Takes a single argument, discards it and return the value that it was called on.

Based on the documentation, this feature returns a constant value instead of any other arguments. The example presented show the result of this feature when applied on a `map` method.

```dart
void main(List<String> arguments) {
  constant();
}

void constant() {
  print("Constant (map):");
  const numbers = [1,2,3];
  final result = numbers.map(0.constant);
  print(result);

  print("Constant (reduce):");
  final result2 = numbers.reduce(0.constant);
  print(result2);

  print("Constant (fold):");
  final result3 = numbers.fold(0, 0.constant);
  print(result3);
}
```

Let run this code.

```console
$ dart run
Building package executable... 
Built tpure:tpure.
Constant (map):
(0, 0, 0)
Constant (reduce):
0
Constant (fold):
0
```

This is syntax sugar around function definition, the previous code is equivalent to:

```dart
void constant() {
  print("Constant (map):");
  const numbers = [1,2,3];
  final result = numbers.map((_) => 0);
  print(result);

  print("Constant (reduce):");
  final result2 = numbers.reduce((_, _) => 0);
  print(result2);

  print("Constant (fold):");
  final result3 = numbers.fold(0, (_,_) => 0);
  print(result3);
}
```

How to use this feature? At this time, I don't really have an idea. I think it can be useful when we return always some constants in an iterable... Or to make less confusing closure notation. The implementation can be seen in [`lib/src/constant/extensions.dart`](https://github.com/purplenoodlesoop/pure/blob/master/lib/src/constant/extensions.dart)

# Composition

A [composition](https://en.wikipedia.org/wiki/Function_composition_(computer_science)) permits to execute functions in pipeline, it uses [`ComposeX`](https://pub.dev/documentation/pure/latest/pure/ComposeX.html) (defined in [`lib/src/composition/dot.dart`](https://github.com/purplenoodlesoop/pure/blob/master/lib/src/composition/dot.dart))and [`PipeX`](https://pub.dev/documentation/pure/latest/pure/PipeX.html) (defined in [`lib/src/composition/pipe.dart`](https://github.com/purplenoodlesoop/pure/blob/master/lib/src/composition/pipe.dart)) types. 

To use this feature, we first need to create a new function. The example provided show how to convert an `int` to a `double` then a `double` to a `String`. Let convert an integer to hexadecimal `String`.

```dart
void composition() {
  print("Composition:");
  final f = (int x) {
    return x.toDouble() + 0.1;
  };

  final g = (double x) {
    return "--" + x.toString() + "--" ;
  };

  final value = 12.pipe(f).pipe(g);
  print(value);
}
```

```console
$ dart run
Building package executable... 
Built tpure:tpure.
Composition:
--12.1--
```

Composition is an extremely powerful mechanism to deal with multi-functions. `pure` is adding the method `pipe()` to all types permitting to use it. The previous example convert an `Int` to a `Double` and finally to a `String`. The computation is clear and each functions can be tested one by one.

# Currying

[Currying](https://en.wikipedia.org/wiki/Currying) is another interesting functional programming mechanism to convert one function with many arguments to a pipeline of functions with one argument. It can be mixed with composition to give more flexibility on complex functions.

```dart
void curry() {
  print("Curry:");
  final f = (int x, int y, int z) {
    return (x, y, z);
  };

  print(f(1,2,3));
  print(f.curry(1));
  print(f.curry(1)(2));
  print(f.curry(1)(2)(3));
}
```

```console
$ dart run
Building package executable... 
Built tpure:tpure.
Curry:
(1, 2, 3)
Closure: (int) => (int) => (int, int, int)
Closure: (int) => (int, int, int)
(1, 2, 3)
```

# Flipping

This feature can be useful when dealing with external functions breaking your convention. It can be seen on Erlang/Elixir for example, most of the functions on Elixir are passing the state first to modify it with the pipeline operator (`|>`), Erlang is usually doing the opposite. In Dart, reversing the arguments positions can simply done with the `flip()` method offered by `pure`. The example from the documentation is way enough to understand this concept.

```dart
void flipping() {
  print("flipping:");
  final person = (String firstname, String lastname) {
    print("$firstname $lastname");
  };
  person("John", "Smith");
  person.flip("Smith", "John");
}
```

```console
$ dart run
John Smith
John Smith
```

The final result is the same, but the arguments were flipped on the second call. Interesting feature to make a code more flexible without modifying the convention you enforced. Not sure it is used a lot though.

# Nullable

Dealing with `null` can be challenging in Dart, and most of the function one will create will avoid using `null` as arguments, but sometimes, it's impossible to avoid. Then, instead of rewriting a part of the function to support null parameters, `nullable` can be used instead.

```dart
void nullable() {
  final concat = (String firstname, String pseudo, String lastname) {
    return [firstname, pseudo, lastname].join(" ");
  };
  print(concat("John", "Johny", "Smith"));
  print(concat.nullable("test", null, null));
}
```

```console
$ dart run
John Johny Smith
null
```

# Recursion

Creating [recursive functions](https://en.wikipedia.org/wiki/Recursion_(computer_science)) in Dart can overflow the stack. Indeed, Dart does not support tail recursive call by default, and a trampoline function must be created to deal with that. Fortunately, `pure` is offering an implementation for this specific use case. To be honest, I don't really like the method used by `pure` to create the trampoline. The syntax is a bit odd, but it's perhaps I'm coming from functional programming. Here a really simple recursive function doing nothing.

```dart
int rec1(int i) {
  if (i<=0) return -1;
  if (i%1024==0) print(i);
  return rec1(i+1);
}

Tram<int> rec2(int i) {
  if (i<=0) return Tram.done(-1);
  if (i%(1024*1024)==0) print(i);
  return Tram.call(() => rec2(i+1));
}

void trampoline() async {
  print("trampoline:");
  await Isolate.run(() {
    try {
      rec1(1);
    }
    catch(e) {
      print(e);
      return -1;
    }
  });

  rec2.bounce(1);
}

void main(List<String> arguments) {
  trampoline();
}
```

```console
$ dart run
trampoline:
1024
2048
3072
4096
5120
6144
7168
8192
9216
10240
11264
12288
13312
14336
15360
16384
17408
18432
19456
20480
21504
Stack Overflow
1048576
2097152
3145728
4194304
5242880
6291456
7340032
8388608
9437184
...
```

`rec1()` function will overflow the stack a bit after the 20k calls, and then throw a Stack Overflow exception. To avoid crashing the main thread, `rec1()` is started inside an Isolate. This is a proof Dart is not compatible with recursive call, or at least, very long recursive calls.

On the other hand, `rec2()` is using the trampoline feature offered by `pure`. When executed, the function will continue until the variable int will overflow (by default, Dart is using 64 bits integers, so, it will take a while). The `Tram.call()` method is used to create the trampoline, then, to use the trampoline, the `bounce()` method is called from the `rec2` reference.

I'm not sure if it's the most elegant way to do that in Dart, but it works. Comparing the performance of this kind of call with a simple iteration can also be nice. 

# Memoization

[Memoization](https://en.wikipedia.org/wiki/Memoization) is a technique to store the result from pure functions. In short, when a pure function is called one time, the returned values is cached. When the same pure function is called another time with the same arguments, because of the purity, the return value will be exactly the same. Instead of re-doing the computation, the value from the cache is returned. This is an optimization mechanism found in many functional programming language, like in [Haskell](https://wiki.haskell.org/Memoization).


```dart
void memoization() {
  print("memoization:");
  final pure = () {
    return (x, y) {
      sleep(Duration(seconds: 3));
      return x + y;
    }.memoize();
  };
  final p = pure();
  print("datetime: ${DateTime.now()}");
  print(p(1,2));
  print("datetime: ${DateTime.now()}");
  print(p(1,2));
  print("datetime: ${DateTime.now()}");
  print(p(3,3));
  print("datetime: ${DateTime.now()}");
  print(p(3,3));
  print("datetime: ${DateTime.now()}");
}
```

```console
$ dart run
memoization:
datetime: 2026-08-24 11:07:36.620523
3
datetime: 2026-08-24 11:07:39.656219
3
datetime: 2026-08-24 11:07:39.656613
6
datetime: 2026-08-24 11:07:42.684693
6
datetime: 2026-08-24 11:07:42.684823
```

As you can see, the first value is taking 3 seconds to be returned (due to the call to `sleep()` function), but the next time the function is called with the same arguments, the result is given instantaneously. This is because the returned values is cached and instead of executing the function twice, the value is simply returned from the cache.

This work very well for pure functions, but when it comes to impure functions, this is another store. A pure function is reproducible, but an impure function can have different output even if the same inputs are passed. In this case, one can have an issue with memoization cache. In short: use it only with pure function.

# Thunk

A [Thunk](https://en.wikipedia.org/wiki/Thunk) is a function injecting arguments to another function. I never really used this kind of feature in the past though.

```dart
void thunk() {
  print("thunk:");
  final t = (num x, num y) => x + y;
  final s = t.thunk(1, 2);
  print(s());
}
```

```console
$ dart run
thunk:
3
```

This feature is straightforward and can be used with repetitive functions call is made. Again, I never used this kind of methods, so, I don't really know where should I use it.

# Conclusion

To be quite honest, doing functional programming in Dart does not seem natural. For example, creating a simple recursive fibonacci sequence in Dart is painful, even with `pure`. This package is offering nice interfaces though, mostly used to glue some of your code with external modules. It's always nice to have this kind of features.

Unfortunately, I don't have a lot of resources to share with you on `pure`:

- [`pure` API documentation](https://pub.dev/documentation/pure/latest/) on pub.dev;

- [`pure` source code`](https://github.com/purplenoodlesoop/pure) on Github;

- [`pure` examples source code](https://github.com/purplenoodlesoop/pure/tree/master/example) on Github;

- [`pure` test suite](https://github.com/purplenoodlesoop/pure/tree/master/test) on Github.

Maybe starting my own functional oriented library in the future could solve that? Not sure, but could be a good idea to learn about Dart types.

EDIT: added `ribs_core` in the list of functional package available.

----

Cover Image by <a href="https://unsplash.com/@sonika_agarwal?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Sonika Agarwal</a> on <a href="https://unsplash.com/photos/water-drop-in-blue-water-9MGe1GfJ4IE?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>