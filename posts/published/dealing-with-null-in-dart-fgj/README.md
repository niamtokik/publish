---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/dealing-with-null-in-dart-fgj"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Frxl15s6leuoeaphsh5bk.jpg"
created_at: "None"
crossposted_at: "None"
description: "Into the void of silence, into the empty space of nothing, the joy of life is unfurled.  -- C. S...."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/dealing-with-null-in-dart-fgj"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "dealing-with-null-in-dart-fgj"
social_image: "None"
title: "Dealing with null in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Dealing with null in Dart

> Into the void of silence, into the empty space of nothing, the joy of life is unfurled.
> 
> -- C. S. Lewis 

Usually, a developer will focus on errors and exceptions to increase the stability of its application. It can be with defensive programming patterns, or like for Erlang, embracing errors and accepts them with the Let it crash philosophy (see also crash-only systems). In Dart... it was weird to see more information about `null` than errors management. In fact, one of the [longest article on dart.dev](https://dart.dev/null-safety/understanding-null-safety) seems to be dedicated to `null` safety. 

How to deal with errors, exceptions and... `null`, in Dart? It will probably be the thing I will hate the most with Dart. Dealing with `null` seems to be really complex, at least, when no external packages are used.

What is `null` anyway?

> The reserved word `null` evaluates to the null object.
> ```
>    ⟨nullLiteral⟩ ::= null
>```
> The `null` object is the sole instance of the built-in class `Null`. Attempting to instantiate `Null` causes a compile-time error. It is a compile-time error for a
class to extend, mix in or implement Null. The `Null` class extends the `Object` class and declares no methods except those also declared by `Object`. The `null` object has primitive equality (10.2.3). The static type of `null` is the `Null` type
> -- Dart Specification, section 17.4, page 103

So, `null` is an unique object only instantiated once during - probably - the initialization.

> The treatment of `null` merits some discussion. Consider `null + 2`. This expression always causes an error. We could have chosen not to treat it as a constant expression (and in general, not to allow null as a subexpression of numeric or boolean constant expressions). There are two arguments for including it: First, it is constant so we can evaluate it at compile time. Second, it seems more useful to give the error stemming from the evaluation explicitly.
> -- Dart Specification, page 101

Errors generate by nulls can be evaluated at compile time, this is helpful for static analysis.

# Bootstrapping

For this article, a new project called `n` will be created. It will be used to play with `null` in Dart.

```console
$ dart create n
Creating n using template console...

  .gitignore
  analysis_options.yaml
  CHANGELOG.md
  pubspec.yaml
  README.md
  bin/n.dart
  lib/n.dart
  test/n_test.dart

Running pub get...                     2.7s
  Resolving dependencies...
  Downloading packages...
  Changed 48 dependencies!

Created project n in n! In order to get started, run the following commands:

  cd n
  dart run

$ cd n
```

# Dissecting Null

The [`Null`](https://api.dart.dev/dart-core/Null-class.html) object got only two attributes, [`hashCode`](https://api.dart.dev/dart-core/Null/hashCode.html) and [`runtimeType`](https://api.dart.dev/dart-core/Object/runtimeType.html). The `hashCode` returns always `0` (zero) and the `runtimeType` returns the `Type` of the object, `Null` in this case. Only two methods are also public, [`noSuchMethod()`](https://api.dart.dev/dart-core/Object/noSuchMethod.html) and [`toString()`](https://api.dart.dev/dart-core/Null/toString.html).

```dart
void main() {
  print(null.hashCode);
  print(null.runtimeType);
}
```

```console
0
Null
```

Let have a quick look on the source code.

```dart
@pragma("vm:entry-point")
final class Null {
  factory Null._uninstantiable() {
    throw UnsupportedError('class Null cannot be instantiated');
  }

  external int get hashCode;

  String toString() => "null";
}
```

The `Null` class is implemented in [`sdk/lib/core/null.dart`](https://github.com/dart-lang/sdk/blob/d684a576a6aa954ae107a03b2b4e1d61c3bebe93/sdk/lib/core/null.dart) as a [`final class`](https://dart.dev/language/class-modifiers#final). It uses a [`vm:entry-point`](https://github.com/dart-lang/sdk/blob/main/runtime/docs/compiler/aot/entry_point_pragma.md) pragma, confirming its presence during initialization. the `_uninstantiable` constructor is a bit odd to me. I don't know if it's convention or something specified somewhere, but because a `factory` is set, I would assume it is a way to protect against creating new instance during runtime. It could be nice to find some ways to call this method.

# Operators

Let have a quick look on the `Null` operators. The first one to check will be the [`!` operator](https://dart.dev/null-safety/understanding-null-safety#not-null-assertion-operator). It is only used if you are sure a variable will never be `null`, if the data is `null`, then it will raise an exception `Null check operator used on a null value`.

```dart
void t1(dynamic? v) {
  var v1 = v!;
  print("t1: ${v1}");
}

void main() {
  t1(1);
  t1(null);
}
```

```console
$ dart run
Building package executable... 
Built n:n.
t1: 1
Unhandled exception:
Null check operator used on a null value
#0      t1 (file:///home/user/tmp/dart/n/bin/n.dart:9:13)
#1      main (file:///home/user/tmp/dart/n/bin/n.dart:5:3)
#2      _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:313:19)
#3      _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:192:12)
```

What to do if the value is `null` but a default value can be used instead? In this situation, the `??` (if-null) operator can be used. 

> An if-null expression evaluates an expression and if the result is the null object (17.4), evaluates another.
> 
> -- [Dart Language Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf), Section 17.25, page 176

```dart
void t2(dynamic? v) {
  var v1 = v ?? "test";
  print(v1);
}

void main() {
  t2(1);
  t2(null);
}
```

```console
$ dart run
Building package executable... 
Built n:n.
t2: 1
t2: default value
```

```dart
void t3(dynamic? v) {
  var v3 = null;
  v3 ??= v;
  print("t3: ${v3}");
}

void main() {
  t3(1);
  t3(null);
}
```

```console
$ dart run
Building package executable... 
Built n:n.
t3: 1
t3: null
```

```dart
void t4(dynamic? v) {
  print(v?.toString());
}

void main() {
  t4(1);
  t4("test");
  t4(null);
}
```

```console
$ dart run
Building package executable... 
Built n:n.
1
test
null
```

```dart
void t5(dynamic? v) {
  print([...? v]);
  print([... v]);
}

void main() {
  t5([1]);
  t5(["test"]);
  t5(null);
}
```

```console
$ dart run
Building package executable... 
Built n:n.
[1]
[1]
[test]
[test]
[]
Unhandled exception:
type 'Null' is not a subtype of type 'Iterable<dynamic>'
#0      t5 (file:///home/user/tmp/dart/n/bin/n.dart:31:14)
#1      main (file:///home/user/tmp/dart/n/bin/n.dart:6:3)
#2      _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:313:19)
#3      _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:192:12)
```

# It's All About Syntactic Sugar

> I consume too much sugar. It’s a problem, I need to stop.
> 
> -- Kevin Jonas

Most of the previous examples are syntactic sugar around the conditional expression. This can be seen in the Figure 3 in the 17.20 section of the Dart Language specification.

> A conditional expression evaluates one of two expressions based on a boolean condition
>
> -- Dart Language Specification, Section 7.24, page 175

Let check these expression by first defining a new class `R` containing one attribute `id` and one method `f`. Nothing complex there, it's just to have a custom object.

```dart
class R {
  dynamic id = null;
  R(dynamic this.id);
  dynamic f(dynamic args) => args;
}
```

The first syntactic sugar to test is `r?.attribute`. If `r` is `null` then it will return `null`, else `r.id` will be used.

```dart
(dynamic, dynamic, bool) sugar1(dynamic r) {
  var a = r?.id;
  var b = r?.id == null ? null : r.id;
  final bool res = a == b;
  final ret = (a,b,res);
  print("sugar1: $ret");
  return ret;
}
```

The second one is the `r?.attribute = e` syntactic sugar. If `r` is `null`, nothing is set, but if it's not the case, the value `e` is set to the `r.id` attribute.

```dart
(dynamic, dynamic, dynamic) sugar2(dynamic r, dynamic e) {
  var a = r?.id = e;
  var b = r == null ? null : r.id = e;
  final bool res = a == b;
  final ret = (a,b,res);
  print("sugar2: $ret");
  return ret;
}
```

The third one is about method calling `r?.f(args)`. If `r` is `null` then it will return null, else the method `f()` is called.

```dart
(dynamic, dynamic, dynamic) sugar3(dynamic r, dynamic args) {
  var a = r?.f(args);
  var b = r == null ? null : r.f(args);
  final bool res = a == b;
  final ret = (a,b,res);
  print("sugar3: $ret");
  return ret;
}
```

The fourth one is about `List`: `r?[e]`. If `r` is `null` then `null` is returned else, the `index` is used on the list `r`.

```dart
(dynamic, dynamic, dynamic) sugar4(dynamic r, dynamic e) {
  var a = r?[e];
  var b = r == null ? null : r[e];
  final bool res = a == b;
  final ret = (a,b,res);
  print("sugar4: $ret");
  return ret;
}
```

The fifth one is still about list, this time, if `r` is `null`, nothing can be done on the list, but if `r` is not `null`, the index `e1` will be used to set the value `e2`.

```dart
(dynamic, dynamic, dynamic) sugar5(dynamic r, dynamic e1, dynamic e2) {
  var a = r?[e1] = e2;
  var b = r == null ? null : r[e1] = e2;
  final bool res = a == b;
  final ret = (a,b,res);
  print("sugar5: $ret");
  return ret;
}
```

Those functions can be added in our entry-point...

```dart
void main() {
  sugar1(R(1));
  sugar1(R(null));
  
  sugar2(R(1), 2);
  sugar2(R(null), 2);
  
  sugar3(R(1), 2);
  sugar3(R(null), 2);
  
  sugar4([1,2,3], 0);
  sugar4(null, 0);
  
  sugar5([1,2,3], 0, 1);
  sugar5(null, 0, 1);
}
```

... And finally invoked.

```console
$ run bin/n.dart
sugar1: (1, 1, true)
sugar1: (null, null, true)
sugar2: (2, 2, true)
sugar2: (2, 2, true)
sugar3: (2, 2, true)
sugar3: (2, 2, true)
sugar4: (1, 1, true)
sugar4: (null, null, true)
sugar5: (1, 1, true)
sugar5: (null, null, true)
```

The results are similar. I know, this is a dummy test, something more accurate could have been done, but it was just to give the equivalent syntax one can use.

# Conclusion

> Nothing exists but atoms and the void.
> 
> -- Democritus 

After a bit more than 1 month of coding with Dart, I found the `null` part exhausting. To me, this part of the language is close to the annoying [error catching in Go](https://go.dev/blog/error-handling-and-go)... Perhaps a little bit better than that though. Adding more and more syntactic sugar to fix a problem like this one can lead to confusing syntax, and it seems to be the case. Using `?`, `??` or `!` in different part of the code makes everything more complex.

As usual, I am not the only one to write about this topic, and it would be a shape to not share all the resources I used to learn about null safety in Dart. Here the list:

- [Understanding null safety](https://dart.dev/null-safety/understanding-null-safety) from the Official Dart documentation;

- [Sound null safety](https://dart.dev/null-safety) from the Official Dart Documentation;

- [Null Safety and Variables](https://dart.dev/language/variables#null-safety) from the Official Dart Documentation;

- [Why nullable types?](https://dart.dev/blog/why-nullable-types) from the Official Dart Blog;

- [The road to Dart 3: A fully sound, null safe language](https://dart.dev/blog/the-road-to-dart-3-a-fully-sound-null-safe-language) from the Official Dart Blog;

- [Announcing Dart null safety beta](https://blog.flutter.dev/announcing-dart-null-safety-beta-4491da22077a) on the Official Dart Blog;

- [`Null` class](https://api.dart.dev/dart-core/Null-class.html) API  documentation;

- [`Null` class implementation source code](http://github.com/dart-lang/sdk/blob/main/sdk/lib/core/null.dart) at Github;

- [Native NULL Assertions](https://github.com/dart-lang/sdk/blob/main/sdk/lib/html/doc/NATIVE_NULL_ASSERTIONS.md?plain=1) from Dart SDK on Github; 

- [Null safety in Dart](https://leancode.co/glossary/null-safety-in-dart) from leancode;

- [Dart Lesson 10: Null Safety (Part 1) — Why is Null Safety Needed? ](https://dev.to/jige2025/dart-lesson-10-null-safety-part-1-why-is-null-safety-needed-5e5g) by @jige2025; 

- [Dart Lesson 11: Null Safety (Part 2) — Safe Operators Explained ](https://dev.to/jige2025/dart-lesson-11-null-safety-part-2-safe-operators-explained-37l8) by @jige2025; 

- [Type Promotion and Nullability in Dart](https://alexanderobregon.substack.com/p/type-promotion-and-nullability-in) by [Alexander Obregon](https://substack.com/@alexanderobregon) on Substack;

- [Understanding Null Safety in Dart: Why It Matters and How to Use It](https://medium.com/@ugamakelechi501/understanding-null-safety-in-dart-why-it-matters-and-how-to-use-it-9619132bce78) by [Ugama Benedicta Kelechi](https://medium.com/@ugamakelechi501) on Medium;

- [Dart: How to Write Shorter Null, False, Empty String, and Zero Checks](https://www.codestudy.net/blog/dart-null-false-empty-checking-how-to-write-this-shorter/) from CodeStudy.net;

- [Mastering Dart's Null Safety: From ? to ! and Everything In Between ](https://dev.to/hiteshm_devapp/mastering-darts-null-safety-from-to-and-everything-in-between-2ic) by @hiteshm_devapp;

- [Master Null Safety in Dart: A Step-by-Step](https://medium.com/@abhaykumarbhumihar/master-null-safety-in-dart-a-step-by-step-865332094f48) by [Abhay Kumar Bhumihar](https://medium.com/@abhaykumarbhumihar) on Medium.

- [STATIC TYPE CHECKER TOOLS FOR DART](https://scholarworks.sjsu.edu/cgi/viewcontent.cgi?article=1284&context=etd_projects) by Snigdha Mokkapati

- [Type Unsoundness in Practice: An Empirical Study of Dart](https://dl.acm.org/doi/pdf/10.1145/3093334.2989227) by Gianluca Mezzetti, Anders Møller and Fabio Strocco

- [Type Soundness in the Dart Programming Language](https://pure.au.dk/ws/files/429018521/Thesis_Fabio_Strocco.pdf) by Fabio Strocco

Have fun! And Hack well!

----

Cover Image by <a href="https://unsplash.com/@nonononononon123?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">aa aaa</a> on <a href="https://unsplash.com/photos/low-angle-photography-of-high-rise-building-ozKAAx6T8-Y?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>