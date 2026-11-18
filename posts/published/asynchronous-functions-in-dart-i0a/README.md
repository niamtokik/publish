---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/asynchronous-functions-in-dart-i0a"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fsptg61ekmk96xneclzw4.jpg"
created_at: "None"
crossposted_at: "None"
description: "In a previous post synchronous functions and iterators have been explained. Those functions are..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/asynchronous-functions-in-dart-i0a"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "asynchronous-functions-in-dart-i0a"
social_image: "None"
title: "Asynchronous Functions in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Asynchronous Functions in Dart

In a previous post synchronous functions and iterators have been explained. Those functions are blocking, and in our daily busy life, we don't want our programs to block, we want a smooth experience. Well, if you are coding in C or C++, you should probably know [pthreads](https://www.man7.org/linux/man-pages/man7/pthreads.7.html), a library used to create threads, a way to create independent computation concurrently. The same exist in many other languages with sometimes different name, but doing mostly the same with just an interface and cool features.

Dart is working a bit like JavaScript, it uses only one thread to do all the computation by default, but this "thread" can be split in many small part allowing the illusion of concurrent or parallel computation. To make that possible, one need to create asynchronous functions, marked with `async` or `async*` keywords.

> A function is asynchronous if its body is marked with the `async` or `async*` modifier. Otherwise the function is synchronous. 
>
> -- [Dart Language Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf), Chapter 9, page 23

What does it really mean? Well, like the very great [Dart documentation part about Concurrency](https://dart.dev/language/concurrency) explains, when a function is asynchronous, the event loop will listen for some changes in "background". When the function returns some values, the event loop receive it and return it to the caller. Let have a look on `async` keyword.

> If f is marked `async`, then a fresh instance is associated with the invocation, where the dynamic type of o implements `Future<T>`, where `T` is the actual type corresponding to the future value type of `f`.
>
> -- [Dart Language Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf), Chapter 17, Section 15, page 141

In short, adding `async` when declaring a new function will mark it as an asynchronous function returning a `Future` object. 

```dart
Future<int> async_int_addition(int x, int y) async {
  return x + y;
}

void main() async {
  print(async_int_addition(1, 2);
  print(await async_int_addition(1, 2));
}
```

```console
$ dart run bin/async.dart 
Instance of 'Future<int>'
3
```

> If f is marked `async*`, then a fresh instances implementing `Stream<U>` is immediately returned, where `U` is the actual type corresponding to the element type of `f`.
>
> -- [Dart Language Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf), Chapter 17, Section 15, page 141

```dart
Stream<int> async_int_generator(int x, int y) async* {
  if (y<x) throw "y<y"; 
  while (x <= y) {
    yield x;
    x++;
  }
}

Future<int> main() async {
  await for (var i in async_int_generator(0, 10)) {
    print(i);
  }
  return 0;
}
```

The previous piece of codes are also using a specific keyword: `await`. Let check the specification to see what does this one is doing.

> An `await` expression allows code to yield control until an asynchronous operation completes. [...] An `await` expression can only occur in a function which is declared asynchronous. The `await` identifier has has no special meaning in the context of a normal function [...] `await(e)` can be a valid function invocation in non asynchronous functions.
>
> -- [Dart Language Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf), Chapter 17, Section 34, page 182

This means if we are using asynchronous function and we want to get the result returned by it, one can use `await` to get it. Bonus point: the value returned will not be a `Future` anymore but the generic type defined. Here an example:

```dart
Future<int> t() async {
  return 1;
}

void main() async {
  print(t());
  print(await t());
}
```

`t()` function is straightforward, it returns simply an integer from an asynchronous call. The `main()` function will print the returned value of this without `await` and with it.

```console
$ dart run bin/await.dart
Instance of '_Future<int>'
1
```

As you can see, the first one returns an instance of `Future`, the "reference" of the execution, while the second would wait until the asynchronous function is done and return an integer.

Asynchronous functions are more than critical in Dart environment and are the foundation of most of the ecosystem. Mastering this part is vital, and if the information provided in this article was not enough, one should probably wait for the next ones on `Future` and `Stream` classes. I underestimated the complexity of this part of the language and thought it could fit in one big post... It was not the case.

Anyway, here more links I can highly recommend to understand how concurrency programming is working with Dart:

- [Concurrency in Dart](https://dart.dev/language/concurrency) from the official Guide, an interesting publication talking a bit about the Dart event loop;

- [Asynchronous programming](https://dart.dev/language/async) from the official Guide where many examples using `async` and `await` can be studied;

- [Dart Language Official Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf) where you can find the expected behaviors of all previous keywords including `async`, `async*`, `yield`, `yield*` and `await`;

- [Dart Async Package Documentation](https://dart.dev/libraries/dart-async) where the `dart:async` package is described, it contains a good introduction;

- [Master Dart: Yield vs Yield* – Unlock Iterable Power](https://dartcounterapp.com/dart-yield-vs-yield/) by [Dieter](https://dartcounterapp.com/author/dietermaes767hotmail-be/). A nice article to understand how `yield` and `yield*` are working;

- [Dart Lesson 13: Asynchronous Programming Basics — Future and async/await](https://medium.com/@jigejiaoxue/dart-lesson-13-asynchronous-programming-basics-future-and-async-await-c9704938121d) by [JiGe](https://medium.com/@jigejiaoxue) on Medium. Another great publication giving some use cases and lot of examples;

- [How can I "sleep" a Dart program](https://stackoverflow.com/questions/18449846/how-can-i-sleep-a-dart-program) on StackOverlow where I found the `sleep()` function was blocking the whole Dart event loop...

----

Image Cover by <a href="https://unsplash.com/@jaruales?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Jose Ruales</a> on <a href="https://unsplash.com/photos/assorted-color-paper-S1jxv58s0UE?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
