---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/synchronous-functions-in-dart-3j08"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fyyz9fqf015gpjt561cdj.jpg"
created_at: "None"
crossposted_at: "None"
description: "This series of post will try to explain a complex topic: concurrent and parallel programming, in..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/synchronous-functions-in-dart-3j08"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "synchronous-functions-in-dart-3j08"
social_image: "None"
title: "Synchronous Functions in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Synchronous Functions in Dart

This series of post will try to explain a complex topic: concurrent and parallel programming, in Dart. I think the only way to deal with that is using the [Erlang VM](https://www.erlang.org/) (BEAM), but [Clojure](https://clojure.org/) and other functional languages are usually doing better job on this part. Unfortunately, to me, most of other languages using OOP don't offer a great abstraction to concurrency and parallelism, but during the last decade, things are changing a bit.

Anyway, before talking about concurrency, parallelism, or even distributed systems, everything starts with synchronous call, the "standard" way to execute a function or a procedure on a computer. In dart, synchronous function call and generators functions need to me studied a little bit. 

Firstly, all function without any specific keyword are all defined as synchronous:

```dart
int addition(int x, int y) {
  return x + y;
}
```

If the keyword `sync` was present in the language, the previous snippet would be equivalent to the one below. Don't try to compile it, it will fail.

```dart
// could be equivalent to the following
// snippet with the sync keyword. But this
// function will not work, sync keyword is
// invalid during compilation
int addition_sync(int x, int y) sync {
  return x + y;
}
```

When adding the `addition()` function inside the `main()` entry-point, it will directly return the value. In fact, you can't really see this because it's quick, but the computer will block a little bit to wait the result of the computation.

```dart
int main() {
  return addition(1, 2);
}
```

A synchronous function will always wait for  any kind of return before continuing the execution of the program. For example, if an infinite loop is created, the function will never return, and the function will block the whole program. The following snippet, when executed, will never return because of the `while` loop defined in the `infinite_loop()` function. The only way to close this program is to kill it (for example using `Ctrl-C` or sending another signal on UNIX systems).

```dart
int infinite_loop() {
  while (true) {
    // do something
  }
  return 0;
}

int main() {
  return infinite_loop();
}
```

Great, we know how to create synchronous functions. Now, let have a look on a specific keyword: `sync*`. This one is a syntactic sugar to help developers creating [generators](https://dart.dev/language/functions#generators), a function that return many elements, one at a time. The best example is the [`List`](https://api.dart.dev/dart-core/List-class.html) class (or `[]`). This data type - a list - is seen as a generator, and more precisely an [`Iterable`](https://api.dart.dev/dart-core/Iterable-class.html).

> A function is a generator if its body is marked with the `sync*` or `async*` modifier. [...] Generator functions are a sugar for functions that produce collections in a systematic way, by lazily applying a function that generates individual elements of a collection. Dart provides such a sugar in both the synchronous case, where one returns an iterable, and in the asynchronous case, where one returns a stream. 
>
> -- [Dart Language Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf), Chapter 9, page 23

Let create our first generator from scratch, let call it `int_generator()`. It will take 2 integers as arguments and will return the list of elements between them. You can see it as a kind of primitive range or sequence function.

```dart
Iterable<int> int_generator(int x, int y) sync* {
  if (y<x) throw "y<x"; 
  while (x <= y) {
    yield x;
    x++;
  }
}

int main() {
  for (var i in int_generator(0, 10)) {
    print(i);
  }
  return 0;
}
```

In the first place, instead of returning a simple `int` this function is returning an `Iterable<int>`. Why? Because we are using `yield`, but we will explain that a bit later. Next, the function definition looks like a classic one, but the `sync*` keyword is added just after. It means this function will be a generator.

Then, the body of the function where a first step is to avoid creating an infinite loop by creating a simple guard throwing an exception if the second argument is less than the first argument. Immediately after, a `while` loop is created, where the first argument is incremented until the first argument is less or equal to the second one. 

> The `yield` statement adds an object to the result of a generator function.
>
> -- [Dart Language Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf), Chapter 18, Section 16, page 213

In this loop, the keyword `yield` followed by variable (or any valid terms) is used. This specific expression is important, because it will adds the object into the result of the generator. In other words, if another function is calling the previous function inside a loop, the sequence of integer will be printed to the screen.

Let execute that from the console.

```console
$ dart run bin/int_generator.dart
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
10
```

`yield` is not the only unique term here able to put an object inside a generator, `yield*` (`yield-each`) can also be used to push a series of objects, in fact a subtype of `Iterable` class.

> The `yield-each` statement adds a series of objects to the result of a generator  function.
>
> -- [Dart Language Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf), Chapter 18, Section 17, page 214

```dart
Iterable<int> int_generator(int x, int y) sync* {
  if (y<x) throw "y<x"; 
  yield* [x,y];
}

int main() {
  print(int_generator(0, 10));
  for (var i in int_generator(0, 10)) {
    print(i);
  }
  return 0;
}
```

Let execute this code.

```console
$ dart run bin/int_each_generator.dart 
(0, 10)
0
10
```

To be honest, I don't currently understand why it returns a record on the first part of the program. I was reading the specification but I was unable to find and answer. I will let this problem for future-me. A quick note though: a generator cannot return a value.

> Case `⟨Generator functions⟩`. It is a compile-time error if a `return` statement of the form `return e`; appears in a generator function.
>
> -- [Dart Language Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf), Chapter 18, Section 12, page 211

Based on the documentation, it also seems `yield*` can be used to improve recursive function performance. Here the one of the previous example implemented using recursive function call.

```dart
Iterable<int> int_rec_generator(int x, int y) sync* {
  if (x<=y) {
    yield x;
    yield* int_rec_generator(x+1, y);
  }
}

int main() {
  print(int_rec_generator(0, 10));
  return 0;
}
```

Let run it now.

```console
$ dart run bin/int_recursive_generator.dart 
(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
```

Same result than before, but it was using a recursive function. If I remember correctly, calling recursively a function in Dart with tail queue optimization and trampoline is a very bad idea (it will consume a lot of stack and memory). Anyway, let switch to another topic: `Iterable` class.

# `Iterable` class

We know how to create generators, and then `Iterable` from scratch, but what we can do with this kind of objects? Let read the definition from the API documentation.

> A collection of values, or "elements", that can be accessed sequentially.
>
> -- Dart Language Documentation, [`Iterable` class](https://api.dart.dev/dart-core/Iterable-class.html)

Not all features will be illustrated there, only the one looking interesting and useful for my own use cases.

- [`Iterate.generate()`](https://api.dart.dev/dart-core/Iterable/Iterable.generate.html) constructor creates a new `Iterable` object using Integer by default (like a Range/Sequence). The second argument offers a way to change the type returned based on the integer sequence produced (a bit like a `map()`).

```dart
int main() {
  var x = Iterable.generate(10);
  print("generate(10): $x");

  var y = Iterable.generate(26, (int x) => String.fromCharCode(x+65));
  print("generate(10, _): $y");

  return 0;
}
```

```console
$ dart run bin/t.dart 
generate(10): (0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
generate(10, _): (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z)
```

- [`Iterable.contains()`](https://api.dart.dev/dart-core/Iterable/contains.html) method returns `true` if the object passed in the first argument is present in the collection of objects managed by the `Iterable`.

```dart
$ cat bin/contains.dart 
void main() {
  var a = Iterable.generate(26, (int x) => String.fromCharCode(x+65));
  print('"A"? ${a.contains("A")}');
  print('65? ${a.contains(65)}');
}
```

```console
$ dart bin/contains.dart 
"A"? true
65? false
```

- [`Iterable.elementAt()`](https://api.dart.dev/dart-core/Iterable/elementAt.html) method returns the element present at the position defined by the first argument. If the position does not exist, it throws a `RangeError` exception.

```dart
$ cat bin/elementAt.dart 
void main() {
  var x = Iterable.generate(10);
  print(x.elementAt(0));
  print(x.elementAt(9));
  print(x.elementAt(1024));
}
```

```console
$ dart bin/elementAt.dart 
0
9
Unhandled exception:
RangeError (index): Index out of range: index should be less than 10: 1024
#0      IndexError.check (dart:core/errors.dart:520:7)
#1      _GeneratorIterable.elementAt (dart:core/iterable.dart:928:16)
#2      main (file:///dart/t/bin/elementAt.dart:5:11)
#3      _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:314:19)
#4      _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:193:12)
```

- [`Iterable.every()`](https://api.dart.dev/dart-core/Iterable/every.html) method returns true if the collection of items satisfies the anonymous function passed in argument.

```dart
$ cat bin/every.dart 
void main() {
  var x = Iterable.generate(10);
  print(x.every((y) => y >= 0 ));
  print(x.every((y) => y == String ));
}
```

```console
$ dart bin/every.dart 
true
false
```

- [`Iterable.fold()`](https://api.dart.dev/dart-core/Iterable/fold.html) method reduces the collection of items using a combine function present in second argument and an initial value defined in the first argument. 

```dart
void main() {
  Iterable<int> i = Iterable.generate(10);
  print(i.fold<int>(1, (v, e) => v + e));

  var s = Iterable.generate(26, (int x) => String.fromCharCode(x+65));
  print(s.fold<String>("string: ", (v, e) => "${v} ${e}"));
}
```

```console
$ dart bin/fold.dart 
46
string:  A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
```

- [`Iterable.forEach()`](https://api.dart.dev/dart-core/Iterable/forEach.html) method iterates of the collection of item. This method returns nothing.

```dart
void main() {
  var list = [1,2,3,4, "end"];
  list.forEach((x) => print(x));
}
```

```console
$ dart bin/forEach.dart 
1
2
3
4
end
```

- [`Iterable.join()`](https://api.dart.dev/dart-core/Iterable/join.html) method joins the collection of item with a `String` and converts all object in the collection t  `String`.

```dart
void main() {
  var list = ["start", 1, 2, 3, "end"];
  print(list.join(", "));
}
```

```console
$ dart bin/join.dart 
start, 1, 2, 3, end
```

- [`Iterable.map()`](https://api.dart.dev/dart-core/Iterable/map.html) method modifies each element of the collection by calling a function defined in the first argument.

```dart
void main() {
  var m = [
    {'a': 1},
    {'b': 2}
  ];
  print(
    m.map(
      (x) => {x.values.first: x.keys.first}
    )
  );
}
```

```console
$ dart bin/map.dart 
({1: a}, {2: b})
```

-  [`Iterable.reduce()`](https://api.dart.dev/dart-core/Iterable/reduce.html) methods is similar to `Iterable.fold()` excepts it does not have an initial value defined.

```dart
void main() {
  Iterable<int> list = Iterable.generate(20);
  print(list.reduce((a, e) {
    print("$a $e");
    if (e%2==0) {
      return a + e;
    }
    else {
      return a;
    }
  }));
}
```

```console
$ dart bin/reduce.dart 
0 1
0 2
2 3
2 4
6 5
6 6
12 7
12 8
20 9
20 10
30 11
30 12
42 13
42 14
56 15
56 16
72 17
72 18
90 19
90
```

Way more methods are available, but it was not expected to go so deep in this post. If you want to go even deeper, you will need to read the test cases and the Dart implementation:

- [`Iterable` test cases](https://github.com/dart-lang/sdk/blob/main/tests/corelib/) can be found in the files `tests/corelib/iterable*.dart` from [Dart SDK](https://github.com/dart-lang/sdk).

- [`Iterable` implementation source code](https://github.com/dart-lang/sdk/blob/main/sdk/lib/core/iterable.dart) can be found in `sdk/lib/core/iterable.dart`.

With these 2 links, you will have more than enough to understand how things are working.

----

Cover Image by <a href="https://unsplash.com/@whmii?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Will H McMahan</a> on <a href="https://unsplash.com/photos/red-and-white-give-way-signage-post-on-street-2s2GuevIqXA?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>