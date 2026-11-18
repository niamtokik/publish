---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/standalone-http-server-with-relic-in-dart-5gf8"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2F1mef5czqirbkjq71rtsl.jpg"
created_at: "None"
crossposted_at: "None"
description: "Instead of creating another classic web server displaying some static value, we will create today a..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/standalone-http-server-with-relic-in-dart-5gf8"
public_reactions_count: "1"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "standalone-http-server-with-relic-in-dart-5gf8"
social_image: "None"
title: "Standalone HTTP Server with Relic in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Standalone HTTP Server with Relic in Dart

Instead of creating another classic web server displaying some static value, we will create today a local cache management over HTTP using Dart and Relic.

```console
$ dart create -t console-full cache_relic
Creating cache_relic using template console-full...

  .gitignore
  analysis_options.yaml
  CHANGELOG.md
  pubspec.yaml
  README.md
  bin/cache_relic.dart
  lib/cache_relic.dart
  test/cache_relic_test.dart

Running pub get...                     0.5s
  Resolving dependencies...
  Downloading packages...
  Changed 48 dependencies!

Created project cache_relic in cache_relic! In order to get started, run the following commands:

  cd cache_relic
  dart run

$ cd cache_relic

$ dart pub add relic
Resolving dependencies... 
Downloading packages... 
+ relic 1.2.0
+ relic_core 1.2.0
+ relic_io 1.2.0
Changed 3 dependencies!
```

# Cache Server

How to store in-memory data in Dart and how to do it correctly? What kind of solution do we have to "share" a reference to an object containing data? Let review the solution I would have used on [Erlang](https://www.erlang.org/)/[Elixir](https://elixir-lang.org/):

- Creating a [`gen_server`](https://www.erlang.org/doc/apps/stdlib/gen_server.html) or [`gen_statem`](https://www.erlang.org/doc/apps/stdlib/gen_statem.html) process using a [`map`](https://www.erlang.org/doc/apps/stdlib/maps.html) as main state with at least 3 interfaces, one to push a value, one to get a value and then one to delete a value. One session would be directly associated with a process, under a [`supervisor`](https://www.erlang.org/doc/apps/stdlib/supervisor.html) using a `one_for_one` or `simple_one_for_one` strategy;

- Creating a public or protected [ETS table](https://www.erlang.org/doc/apps/stdlib/ets.html) managed by a process following the same principle than the previous point (in short, replacing the [`map`](https://www.erlang.org/doc/apps/stdlib/maps.html) with the ETS). Instead of using Erlang messages via [`gen_server`](https://www.erlang.org/doc/apps/stdlib/gen_server.html) or [`gen_statem`](https://www.erlang.org/doc/apps/stdlib/gen_statem.html), here we could use the [`ets`](https://www.erlang.org/doc/apps/stdlib/ets.html) interface instead (faster).

Dart is a more complex language, you have in this situation many choices available, and each one should probably tested and profiled before being used. Let try to list them one by one.

Why a cache server? Well, to be, a cache system is the smallest piece of software one can found everywhere. There is a reason why [`redis`](https://redis.io/), [`memcached`](https://www.memcached.org/) or many other projects like that are used by everybody: developers need a way to store data quick. It could be for a session, for temporary data or simply to avoid annoying the main core database. A cache service is easy to create (key/value store), and can become rapidly something cool to hack. In fact, if you look a bit closely, any web server or database can be seen as a kind of "infinite" cache server, right?

Oh, by the way, all [articles published in the French Linux Magazine](https://connect.ed-diamond.com/auteur/kerjouan-mathieu) regarding Erlang were created around a cache system service. Feel free to check them.

## Global Variables

A global variable containing an Object like a [`Map()`](https://api.dart.dev/dart-core/Map-class.html) containing `Session()` objects. Using global variables are not a good idea, even in Dart, but it's a simple answer and it should work. The big risk here would be the race conditions and other weird behaviors in case of concurrent calls. Here some list to see what we can do with this method. Here a list of few discussion from the web when it comes to use a global variable in Dart: 

- [How to Store Global Variables in Flutter: The Best Approaches Explained](https://medium.com/@navinprince.thegr8gossiper/how-to-store-global-variables-in-flutter-the-best-approaches-explained-cde516badf84) at Medium;

- [Do you use global variables in your app design?](https://www.reddit.com/r/FlutterDev/comments/1c1gqrx/do_you_use_global_variables_in_your_app_design/) from a reddit thread.

So, I would like to avoid using a global variable (for example in module entry-point), I think it could lead to more issues. It could be a good idea to do a quick test though...

## Singleton pattern

> In object-oriented programming, the singleton pattern is a software design pattern that restricts the instantiation of a class to a singular instance [...] Singletons are often preferred to global variables because they do not pollute the global namespace (or their containing namespace).
>
> -- [Singleton pattern](https://en.wikipedia.org/wiki/Singleton_pattern) on Wikipedia

Object Oriented Programming Design Patterns, a complex topic where programming patterns are standardized and used as common bricks to create something more complex. It was always a pain to work with that to be...

Anyway, let talk a bit about the [singleton pattern](https://en.wikipedia.org/wiki/Singleton_pattern). When an object is created and instantiated from a specific class , a part of the memory is allocated for it. If you are recreating another object with the same class, another part of the memory will be allocated, both objects living in their own space. A singleton is a pattern that will eventually (on demand for example) return an object already instantiated instead of created a new one. To do that in Dart, we also need to talk about the [factory method pattern](https://en.wikipedia.org/wiki/Factory_method_pattern).

> In object-oriented programming, the factory method pattern is a design pattern that uses factory methods to deal with the problem of creating objects without having to specify their exact classes. Rather than by calling a constructor, this is accomplished by invoking a factory method to create an object.
>
> -- [Factory method pattern](https://en.wikipedia.org/wiki/Factory_method_pattern) on Wikipedia

The idea here is to allow a method or a function to create different objects from different classes. Those object can be stored in another object in Map for example or any other data-structure. This kind of behavior can be achieved by using the `factory` keyword.

> A factory is a constructor prefaced by the built-in identifier (17.38) factory.
> 
> -- [Dart Language Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf), Chapter 10, Section 7.2, page 51

Thanks for the information. It does not give us more information about how `factory` is being used though.

> Instance creation expressions generally produce instances and invoke constructors to initialize them. The exception is that a factory constructor invocation works like a regular function call. It may of course evaluate an instance creation expression and thus produce a fresh instance, but no fresh instances are created as a direct consequence of the factory constructor invocation.
>
> -- [Dart Language Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf), Chapter 17, Section 13, page 135

That's a bit better. Indeed, the `factory` function looks like a regular function, and produce fresh instances or create new ones.

> A factory constructor can be declared in an abstract class and used safely, as it will either produce a valid instance or throw
>
> -- [Dart Language Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf), Chapter 17, Section 13.2, page 137

That's part of the specification is also interesting, it means a factory can be part of an abstract class, then, the factory can be used from it to produce objects from a subclass.

The official documentation is listing few examples about [factory constructors](https://dart.dev/language/constructors#factory-constructors), and they give an idea when it could be used.

> In object-oriented programming, the factory method pattern is a design pattern that uses factory methods to deal with the problem of creating objects without having to specify their exact classes. Rather than by calling a constructor, this is accomplished by invoking a factory method to create an object. 
>
> -- [Factory method pattern](https://en.wikipedia.org/wiki/Factory_method_pattern) on Wikipedia

Perhaps having other point of view could help to understand how this thing is working. Here a list of resources from the web:

- [Factory constructors](https://dart.dev/language/constructors#factory-constructors) from the official Dart documentation;

- [Mastering the Singleton Pattern in Dart](https://dev.to/devdammak/mastering-the-singleton-pattern-in-dart-4gin) by @devdammak 


- [Singleton is a Design Pattern in Dart](https://medium.com/@swe.jamirulinfo/singleton-is-a-design-pattern-in-dart-98dd947c6dd1) by [Jamirul islam](https://medium.com/@swe.jamirulinfo) on Medium

- https://medium.com/@hpatilabhi10/mastering-the-singleton-design-pattern-in-dart-40adb7dd87ec 

- [Singleton Pattern in Dart](https://dev.to/blackcoda/dart-singleton-demystified-pdl) by @blackcoda 

- [Understanding Factory Constructors in Dart and Flutter: A Comparison with Static Methods](https://medium.com/@shemsedinrobsen/understanding-factory-constructors-in-dart-and-flutter-a-comparison-with-static-methods-d03b471a7944) by [Shemsedin](https://medium.com/@shemsedinrobsen) on Medium

- [How do you build a Singleton in Dart?](https://stackoverflow.com/questions/12649573/how-do-you-build-a-singleton-in-dart) on StackOverflow

Using the `factory` keyword here, is it really for creating a singleton? Let create a class called `Singleton` to understand this concept.

```dart
class Singleton {
  static String _name = "singleton";
  static int _counter = 0;
  
  Singleton();
  
  factory Singleton.create() => Singleton();
 
  static int increment() => _counter++;
  
  static int decrement() => _counter--;
  
  static int reset() => _counter=0;

  int get counter => _counter;

  String get name => _name;

  String toString() => "counter (${name}): ${counter}";
}
```

The `_name` and `_counter` attributes are private. They will be used to identify the singleton, to see if the instance is really the same. We can also add a random value instead of the fixed one for the name, but it would be too overkill for a simple test.

The constructor `Singleton()` simply returns an instantiated `Singleton` object and do no more. Then the `create()` method is marked as `factory`, so, in theory, it should also return the same instance of a `Singleton` object.

Then, `increment()`, `decrement()` and `reset()` methods are simply there to play with the `_counter` private attribute to see if when we change one instance, the other variables/functions pointing out this instance will change as well.

Finally, 2 getters are created to easily retrieve the values of the private attributes. The last method called `toString()` is a simple boilerplate to convert the `Singleton` as `String`.

Great, now, let creates an instance of a `Singleton` inside a synchronous functions called `f()`.

```dart
void f() {
  Singleton v = Singleton();
  print("f() name: ${v.name}");
  print("f() counter: ${v.counter}");
  Singleton.increment();
}
```

Let do the same but for an asynchronous function call this time, using a `Future` and being delayed of 1 second. This function will be called `a()`.

```dart
Future<void> a() async {
  Future
    .delayed(Duration(seconds: 1))
    .then((_) {
      Singleton v = Singleton();
      print("a() name: ${v.name}");
      print("a() counter: ${v.counter}");
      Singleton.decrement();
    });
}
```

An helper function to inspect the content of the `Singleton` object can also be good. It could be created directly as a method inside it, or, like in this case, as a function called `inspect()`.

```dart
void inspect(Singleton s, {String label = ""}) {
  print("counter (${label}): ${s.counter}");
  print("name (${label}): ${s.name}");
}
```

Our code looks good, but the entry-point is still missing, let create our `main()` function. This one will contain most of the interesting stuff, and will try to instantiate many `Singleton()` objects to see if the values similar or different.

```dart
Future<void> main() async {
  // create a first instance
  Singleton v1 = Singleton();
  Singleton.increment();
  inspect(v1, label: "v1");
  
  // try to create a second instance
  // and increment the counter
  Singleton v2 = Singleton();
  inspect(v2, label: "v2");
  Singleton.increment();
    
  // check both instance (should return the same
  // values)
  inspect(v1, label: "v1");
  inspect(v2, label: "v2");

  // reset the singleton
  Singleton.reset();
  inspect(v1, label: "v1");
  inspect(v2, label: "v2");
  
  // asynchronous function call
  a();
  
  // create a third instance
  Singleton v3 = Singleton();
  inspect(v3, label: "v3");
  inspect(v2, label: "v2");
  inspect(v1, label: "v1");
  
  // synchronous function call
  f();
} 
```

This code can be invoked, and here the result:

```console
$ dart run bin/singleton.dart
counter (v1): 1
name (v1): singleton
counter (v2): 1
name (v2): singleton
counter (v1): 2
name (v1): singleton
counter (v2): 2
name (v2): singleton
counter (v1): 0
name (v1): singleton
counter (v2): 0
name (v2): singleton
counter (v3): 0
name (v3): singleton
counter (v2): 0
name (v2): singleton
counter (v1): 0
name (v1): singleton
f() name: singleton
f() counter: 0
a() name: singleton
a() counter: 1
```

Yeah, it seems the singleton pattern is working there. Even when we try to instantiate a new `Singleton()` object during the execution of the program, the values returned seems similar. I assume then the returned object is always the same. Anyway, I still don't understand everything, it's probably due to the syntax:

- when using the constructor, the same instance is returned, does it means when any kind of method is marked with a `factory` keyword, it will only act as a factory?

- what about race condition and asynchronous calls? Is it really safe to have a singleton in this kind of context? It looks like a global variable to me, so, I guess the same issues will be present.

## Multiton Pattern

Another concept pattern exists, called  [multiton pattern](https://en.wikipedia.org/wiki/Multiton_pattern), permits to manage more than one object. In fact, it seems this is the example made by the [Dart documentation](https://dart.dev/language/constructors#factory-constructors) when talking about factories, at least, if the wikipedia can be trusted:

> In software engineering, the multiton pattern is a design pattern which generalizes the singleton pattern. Whereas the singleton allows only one instance of a class to be created, the multiton pattern allows for the controlled creation of multiple instances, which it manages through the use of a map.
>
> -- [Multiton pattern](https://en.wikipedia.org/wiki/Multiton_pattern) on Wikipedia

So, what's the idea there? Well, instead of creating one instance of one object, and reusing every time, the multiton pattern deals with many objects stored somewhere, usually a [Map](https://api.dart.dev/dart-core/Map-class.html) like in the example. Let recreate it.

```dart
class Multiton {
  int _counter = 0;
  String _id  = "";

  final String _name = "multiton";
  static final Map<String, Multiton> _cache = <String,Multiton>{};

  factory Multiton(String id) {
    return _cache.putIfAbsent(id, () => Multiton._init(id));
  }

  Multiton._init(this._id);

  String get name => _name;

  int get counter => _counter;

  String get id => _id;

  static int length() => _cache.length;
  
  int increment() => _counter++;

  static Map<String, Multiton> get cache => _cache;

  static void remove(String id) {
    print("==> remove ${id}");
    _cache.remove(id);
  }
  
  void inspect({String? label = null}) {
    print("--");
    if (label != null) print("label: ${label}");
    print("multiton_length: ${length()}");
    print("object_hashCode: ${hashCode}");
    print("  object_id: ${_id}");
    print("  object_counter: ${_counter}");
    print("  object_name: ${_name}");
  }
}
```

Okay, it looks like a bit more complex than the singleton. The most complex part is about the `_cache` attribute, it will store the `Multiton` instance using a key as `String` when a new `Multiton` is created. 

the `inspect()` method has been added directly inside the class to help to see what's happening. Note: only a `Multiton` instance can execute it, it's not possible to call it via the class itself like `Multiton.inspect()`.

Let create then `main()` entry-point now. 

```dart
void main() {
  // create a first multiton instance
  // with the id "test" and increment
  // its counter
  var m1 = Multiton("test");
  m1.inspect(label: "m1");
  m1.increment();

  // create a second multiton instance
  // using the same id "test", this should
  // be the same instance than m1.
  var m2 = Multiton("test");
  m2.inspect(label: "m2");

  // create a third multiton instance
  // with "test2" as id. It should be
  // a new instance.
  var m3 = Multiton("test2");
  m3.inspect(label: "m3");
  m3.increment();
  m3.increment();
  m3.increment();
  m1.inspect(label: "m1");
  m2.inspect(label: "m2");
  m3.inspect(label: "m3");

  // let remove the multiton using
  // "test" as id and recreate a new
  // one. the counter should be reset
  // to 0
  Multiton.remove("test");
  var m4 = Multiton("test");
  m4.inspect(label: "m4");
  
  // let remove it again
  // but because of garbage collector,
  // the value is still there.
  Multiton.remove("test");
  m4.inspect(label: "m4");
  
  // let remove the last id "test2"
  // and print the length of the multiton
  // it should be equal to 0
  Multiton.remove("test2");
  print(Multiton.length());
}
```

To help me (and the readers), some comments have been added. Dealing with multiple instance of objects can be challenging, and I did not even add the asynchronous part. Anyway, the idea there is to instantiate `Multiton()` objects in different manners. We can also play a bit with the garbage collector.

Indeed, the 2 last `inspect()` call are interesting. When we remove the key `"test"` from the `_cache`, we still have one instance of this object alive, because we are reusing the `m4` variable. When we remove all keys, the `_cache` length drop to `0` and in theory, because no more variables are being used, all instances have been removed.

```console
--
label: m1
multiton_length: 1
object_hashCode: 779530408
  object_id: test
  object_counter: 0
  object_name: multiton
--
label: m2
multiton_length: 1
object_hashCode: 779530408
  object_id: test
  object_counter: 1
  object_name: multiton
--
label: m3
multiton_length: 2
object_hashCode: 938446565
  object_id: test2
  object_counter: 0
  object_name: multiton
--
label: m1
multiton_length: 2
object_hashCode: 779530408
  object_id: test
  object_counter: 1
  object_name: multiton
--
label: m2
multiton_length: 2
object_hashCode: 779530408
  object_id: test
  object_counter: 1
  object_name: multiton
--
label: m3
multiton_length: 2
object_hashCode: 938446565
  object_id: test2
  object_counter: 3
  object_name: multiton
==> remove test
--
label: m4
multiton_length: 2
object_hashCode: 702292414
  object_id: test
  object_counter: 0
  object_name: multiton
==> remove test
--
label: m4
multiton_length: 1
object_hashCode: 702292414
  object_id: test
  object_counter: 0
  object_name: multiton
==> remove test2
0
```

A quick summary, I find the interface and all the syntactic sugar highly confusing here. It's really like black magic under steroids, the code is working, but you don't really know why and you are a bit afraid of the answer.

Unfortunately, the cache service will use the multiton patterns to store each sessions. When an user will store some value, the session requested will also have access to the cache store and offers getters/setters to modify it.

## Observer pattern (Observables)

> In software design and software engineering, the observer pattern is a software design pattern in which an object, called the subject (also known as event source or event stream), maintains a list of its dependents, called observers (also known as event sinks), and automatically notifies them of any state changes, typically by calling one of their methods.
>
> [Observer pattern](https://en.wikipedia.org/wiki/Observer_pattern) on Wikipedia

While I was looking for an answer, some people pointed another solution called the observer pattern. Unfortunately, the package called [`observable`](https://pub.dev/documentation/observable/latest/observable/) I wanted to use is not maintained anymore. An alternative called [`simple_observable`](https://pub.dev/packages/simple_observable) though. It will be the subject for another publication. Here some interesting link from the web about observer pattern in Dart:

- [Observer Pattern](https://github.com/scottt2/design-patterns-in-dart/blob/master/observer/README.md) by [Tyler Scott](https://github.com/scottt2) on Github

- [Design Pattern in Dart: Observer Pattern](https://blog.devblocks.tech/design-pattern-trong-dart-observer-pattern/) by [Lotus Blog](https://blog.devblocks.tech/user/nguyennhutthong.devgmail-com/)

- [Implement an Observer pattern in Dart](https://stackoverflow.com/questions/20186198/implement-an-observer-pattern-in-dart) on StackOverflow

- [Understanding Flutter Observables](https://medium.com/@gauravswarankar/understanding-flutter-observables-cb0277f85174) by [Gaurav Swarankar](https://medium.com/@gauravswarankar) on Medium

- [Reactive Programming in Flutter: Understanding the Power of Observables and Computed Values with Signals, Riverpod and RxDart](https://www.christianfindlay.com/blog/flutter-rx-signals-riverpod-rxdart) by [Christan Findlay](https://www.christianfindlay.com/)

- [How to write your own observables in dart.](https://medium.com/@yadunandan.xyz/how-to-write-your-own-observables-in-dart-15a2c9d36be5) by [yadunandan](https://medium.com/@yadunandan.xyz) on Medium

- [Why the Observer Pattern is Essential for Flutter Developers?](https://medium.com/@mo7amedaliebaid/why-the-observer-pattern-is-essential-for-flutter-developers-214ce2f5e0d5) by [Moamedaliebaid](https://medium.com/@mo7amedaliebaid) on Medium

# Common Functions

The cache service will use Base64Url specified in [RFC4648](https://www.rfc-editor.org/info/rfc4648/#section-5). What's the difference with Base64? Well, this format is URL-friendly, and replace the `+` plus) and the `/` (slash) respectively by `-` (dash) and `_` (underscore). It means base64url can easily be passed in a path. Let create the file `lib/base64url.dart`.

**Bloody Eyes Alert**: the implementation used here is disgustingly slow and crappy on purpose, I wanted to test the [RegExp](https://api.dart.dev/dart-core/RegExp-class.html) interface in Dart... 

```dart
String toBase64Url(String base64) {
  return base64
    .replaceAllMapped(
      RegExp(r'\+'),
      (Match m) => '-'
    )
    .replaceAllMapped(
      RegExp(r'\/'),
      (Match m) => '_'
    );
}
```

The `toBase64Url()` function simple replace `+` and `/` by `-` and `_` with the help of [`String.replaceAllMapped()`](https://api.dart.dev/stable/3.11.5/dart-core/String/replaceAllMapped.html) method. A new [`RegExp()`](https://api.dart.dev/dart-core/RegExp-class.html) is used there to replace all characters.

```dart
String toBase64(String base64) {
  return base64
    .replaceAllMapped(
      RegExp(r'\-'),
      (Match m) => '+'
    )
    .replaceAllMapped(
      RegExp(r'\_'),
      (Match m) => '/'
    );
}
```

The `toBase64()` function is doing the opposite of the previous function (and uses the same structure).

```dart
bool isBase64Url(String b64) {
  try {
    base64.decode(toBase64(b64));
    return true;
  }
  catch (_) {
    return false;
  }
}
```

Finally, `isBase64Url()` checks if a Base64 string is valid or not. Again, dirty code where the Base64Url is converted to [Base64](https://api.dart.dev/dart-convert/Base64Codec-class.html) and then [decoded](https://api.dart.dev/dart-convert/Base64Decoder-class.html).

Is there a better method? Yes. In fact, doing my own implementation of Base64Url could have been done, it would have been faster, but would also mean more work. The goal is not to have production ready tool, but to learn the most from Dart.

# Store

The `Store` class will be one of the most important, it will contain the key/value defined by the clients. The definition should be flexible to accept any kind of data. The checks will be done before inserting data (in the handlers or middlewares).

```dart
class CacheStore {
  static final Map<String, String> _store= <String, String>{};

  CacheStore();

  bool exists(String key) => _store.containsKey(key);

  int length() => _store.length;

  String put(String key, String value) {
    _store[key] = value;
    return key;
  }

  String? get(String key) => _store[key];
  
  String? delete(String key) => _store.remove(key);
}
```

This class definition is simple, a `_store` attribute will contain the keys/values, and the `get()`, `delete()`, `put()` and `exists()` methods the interfaces to interact with it. The test suite can be seen below.

```dart
store_test() {
  group('store', () {
    test('create a new store', () {
      expect(CacheStore(), isA<CacheStore>());  
    });
    test('insert and deleting keys', () {
      CacheStore s = CacheStore();
      expect(s.length(), equals(0));

      s.put("test", "test");
      expect(s.get("test"), equals("test"));
      expect(s.length(), equals(1));
      expect(s.exists("test"), equals(true));

      s.delete("test");
      expect(s.get("test"), equals(null));
      expect(s.exists("test"), equals(false));
      expect(s.length(), equals(0));
    });
  });
}
```

Let execute them to be sure it works correclty.

```console
$ dart test
00:00 +2: All tests passed!
```

Looks good to me. Go to the next stack.

# Session

The `Session` class is our multiton, it will be in charge to manage the session by their id. Each session got one `Store()` object. This module is from `lib/session.dart`.

```dart
import 'dart:core';
import 'dart:math';
import 'dart:convert';
import 'cache_store.dart';
import 'base64url.dart';
```

```dart
class CacheSession {
  final String sessionId;
  final CacheStore cache = CacheStore();  

  static final Map<String, CacheSession> _sessions = <String, CacheSession>{};
 
  factory CacheSession(String id) {
    return _sessions.putIfAbsent(id, () {
      return CacheSession._init(id);
    });
  }

  CacheSession._init(this.sessionId);

  static bool exists(String id) {
    return _sessions.containsKey(id);
  }

  static String? delete(String sessionId) {
    if (_sessions.remove(sessionId) != null) {
      return sessionId;
    }
    return null;
  }

  String toString() => sessionId;
}
```

The most important part of the code is from the constructor `CacheSession` marked with the `factory` keyword. Every time a new `Session()` object is created, it will check if a similar object is already present using the session id. The `exists()` function can check if an existing object is associated with a key and the `delete()` method can remove an instantiated object from the session store if needed. This multiton implementation is similar to the one previously implemented at the beginning of this publication. Then, we need a way to check a session id.

```dart
bool checkSessionId(String sessionId) {
  if (sessionId.length>32) {
    return false;
  }
  RegExp regexp = RegExp(r'^([a-zA-Z0-9_-])+$');
  if (regexp.firstMatch(sessionId) == null) {
    return false;
  }
  return true;
}
```

A session id is a base64url like String, with - for the moment - a fixed length of 32 characters. It should be enough to avoid collision. The `checkSessionId()` function is dealing with that, but how to generate a random session id?

```dart
String generateSessionId(int length) {
  List<int> buf = [];
  final r = Random.secure();
  for (;length>0;length--)
    buf.add(r.nextInt(1<<8));
  return base64url(buf);
}
```

Well, the `generateSessionId()` function will generate a random session id as Base64url String using `Random.secure()` object from `dart:math` package. The returned String is cryptographically secure (at least, if one can trust the Dart API documentation).

```dart
String base64url(List<int> list) {
  String b64 = base64.encode(list);
  return toBase64Url(b64);
}
```

The last function called `base64url()` converts a list of integers to a base64url `String`.

```dart
session_test() {
  group('session', () {
    test('create a new session store', () {
      expect(CacheSession("test"), isA<CacheSession>());
    });
    test('dealing with sessions', () {
      var s = CacheSession("test");
      s.cache.put("test", "test");
      expect(s.cache, isA<CacheStore>());
      expect(CacheSession.exists("test"), equals(true));
      expect(s.cache.get("test"), equals("test"));

      var s2 = CacheSession("test2");
      s2.cache.put("test2", "data");
      expect(s.cache, isA<CacheStore>());
      expect(CacheSession.exists("test2"), equals(true));
      expect(s.cache.get("test2"), equals("data"));

      CacheSession.delete("test");
      expect(CacheSession.exists("test"), equals(false));

      CacheSession.delete("test2");
      expect(CacheSession.exists("test2"), equals(false));
      
    });
  });
}
```

```console
$ dart test
00:00 +4: All tests passed!
```

# Relic Handlers

The previous parts were talking about the logic of the application, the next parts will talk about the integration of this logic with [Relic](https://pub.dev/packages/relic), a pure Dart HTTP server.

A relic server is using [handlers](https://docs.dartrelic.dev/reference/handlers) to deal with [`Request()`](https://pub.dev/documentation/relic/latest/relic/Request-class.html) objects. A request is made when a client is requesting data from a server. A `Request()` object got some really interesting attributes and methods, mostly used to route it:

- [`body`](https://pub.dev/documentation/relic/latest/relic/Message/body.html) property, contains the body of the request as `Stream`;

- [`connectionInfo`](https://pub.dev/documentation/relic/latest/relic/Request/connectionInfo.html) property, contains a [`ConnectionInfo`](https://pub.dev/documentation/relic/latest/relic/Request/connectionInfo.html) object which store the client IP address and TCP port information;

- [`header`](https://pub.dev/documentation/relic/latest/relic/Message/headers.html) property, contains the HTTP [Headers](https://pub.dev/documentation/relic/latest/relic/Headers-class.html) of the client;

- [`method`](https://pub.dev/documentation/relic/latest/relic/Request/method.html) property, containing the HTTP method used by the client like GET or POST;

- [`queryParameters`](https://pub.dev/documentation/relic/latest/relic/QueryParametersRequestEx/queryParameters.html) property, contains the queries passed by the client;

- [`rawPathParameters`](https://pub.dev/documentation/relic/latest/relic/RoutingRequestEx/rawPathParameters.html) property contains the parameters parsed from the path;

- [`url`](https://pub.dev/documentation/relic/latest/relic/Request/url.html) property contains the full url used by the client;

- [`read`](https://pub.dev/documentation/relic/latest/relic/Message/readAsString.html) and [`readAsString`](https://pub.dev/documentation/relic/latest/relic/Message/read.html) methods are used to extract the body from the request.

After applying the logic on a [`Request()`](https://pub.dev/documentation/relic/latest/relic/Request-class.html) object, an [`Handler`](https://pub.dev/documentation/relic/latest/relic/HandlerObject-class.html) should return a [`Response()`](https://pub.dev/documentation/relic/latest/relic/Response-class.html) object. This response will help to return a specific message to the client when using one of those [constructors](https://pub.dev/documentation/relic/latest/relic/Response-class.html#constructors):

- [`Response.ok()`](https://pub.dev/documentation/relic/latest/relic/Response/Response.ok.html) to return a 200 OK HTTP response;

- [`Response.notFound()`](https://pub.dev/documentation/relic/latest/relic/Response/Response.notFound.html) to return a 404 NOT FOUND HTTP Response;

- [`Response.internalServerError()`](https://pub.dev/documentation/relic/latest/relic/Response/Response.internalServerError.html) to return a 500 Internal Server Error HTTP Response.

More of them are present in the documentation, don't hesitate to use the one required for your needs.

Anyway, come back to the cache application; those handlers are currently stored in `lib/handlers.dart` but a better convention would probably to store them by features. Here the header.

```dart
import 'dart:math';
import 'package:relic/relic.dart';
import 'store.dart';
import 'session.dart';
```

The first step for a client is to ask for a session, on the path `/sessions`. A session id is generated (base64url `String`) and returned to the client only if the server can do it. This feature is defined by the `newSessionHandler()` function.

```dart
Response newSessionHandler(final Request req) {
  final String sessionId = generateSessionId(16);
  var s = CacheSession(sessionId);
  return Response.ok(
    body: Body.fromString(sessionId),
  );
}
```

A client can also check if one of its session is existing (or not). In this case, it will check the path `/sessions/:session` where `:session` is a session id. If the session exists, the server returns a 200 OK, if not, a 404 NOT FOUND. The `getSessionHandler()` function is taking care of this handler.

```dart
Response getSessionHandler(final Request req) {
  final String sessionId = req.rawPathParameters[#session]!;
  if (CacheSession.exists(sessionId)) {
    return Response.ok(
      body: Body.fromString("")
    );
  }
  return Response.notFound(
    body: Body.fromString("")
  );
}
```

A client can also remove a session by using the `/session/:session` path with the help of the `DELETE` HTTP method. This feature is implemented in the `deleteSessionHandler()` function.

```dart
Response deleteSessionHandler(final Request req) {
  final String sessionId = req.rawPathParameters[#session]!;
  String? id = CacheSession.delete(sessionId);
  if (id != null) {
    return Response.ok(
      body: Body.fromString(id),
    );
  }
  return Response.notFound(
    body: Body.fromString('not found'),
  );
}
```

A client with a valid session id can see the number of keys set in the cache by using the `/sessions/:session/keys`. This is currently not implemented, but it will be managed by the `getCacheLengthHandler()` function.

```dart
Future<Response> getCacheLengthHandler(final Request req) async {
  final String sessionId = req.rawPathParameters[#session]!;
  final CacheSession s = CacheSession(sessionId)!;

  return Response.ok(
    body: Body.fromString(s.cache.length().toString()),
  );
}
```

A client with a valid session id can retrieve a key from a cache with the path `/cache/:session/:key` where `:key` is a String used as key in the cache store. This feature is implemented in the `getCacheHandler()` function.

```dart
Future<Response> getCacheHandler(final Request req) async {
  final String sessionId = req.rawPathParameters[#session]!;
  final CacheSession s = CacheSession(sessionId)!;
  final key = req.rawPathParameters[#key]!;

  if (!s.cache.exists(key))
    return Response.notFound(
      body: Body.fromString("not found"),
    );

  String? value = s.cache.get(key);

  if (value != null)
    return Response.ok(
      body: Body.fromString(value),
    );
  else
    return Response.ok(
      body: Body.fromString(""),
    );
}
```

A client with a valid session id can also create a new key with a value. In this case, the client will use the `/cache/:session/:key` with the HTTP POST method. The body of the request will be the value associated with the key (then the data stored in the cache). This feature is implemented in `postCacheHandler()` function.

```dart
Future<Response> postCacheHandler(final Request req) async {
  final String sessionId = req.rawPathParameters[#session]!;
  final CacheSession s = CacheSession(sessionId)!;
  final key = req.rawPathParameters[#key]!;

  String body = await req.readAsString(maxLength: 10000);

  s.cache.put(key, body);
  return Response.ok(
    body: Body.fromString("ok"),
  );
}
```

Finally, a client with a valid session can also delete a key/value using the `/cache/:session/:key` path and with the `DELETE` HTTP method. The `deleteCacheHandler()` function was created to implement this behavior.

```dart
Future<Response> deleteCacheHandler(final Request req) async {
  final String sessionId = req.rawPathParameters[#session]!;
  final CacheSession s = CacheSession(sessionId)!;
  final key = req.rawPathParameters[#key]!;

  s.cache.delete(key);
  return Response.ok(
    body: Body.fromString("ok"),
  );
}
```

I still don't really know how to deal with the tests though, so, it will be done later. For now, the handlers created there are pretty simple and should not do lot of mess.

# Relic Middleware

A Relic [Middleware](https://docs.dartrelic.dev/reference/middleware) can be seen as a pipeline. It will got a request as input, modify it and returns it as input, before any handlers. A feature called [Pipeline](https://docs.dartrelic.dev/reference/pipeline) was previously available from Relic, but it is now deprecated.

A [Middleware](https://pub.dev/documentation/relic/latest/relic/Middleware.html) 

- https://pub.dev/documentation/relic/latest/relic/MiddlewareObject-class.html

In our case, the middlewares are currently all stored in `lib/middlewares.dart` module; we don't have a lot of them, so, it should be okay for the moment.

```dart
import 'package:relic/relic.dart';
import 'store.dart';
import 'session.dart';
```

One of the middleware, called `checkSessionId()` will be in charge to check if a session id exists or not. If it does not exist, a 404 not found is returned.

```dart
/// check if the session id has been defined in the
/// URL path.
Middleware checkSessionId() {
  return (final Handler next) {
    return (final Request req) async {
      final sessionId = req.rawPathParameters[#session];
      if (sessionId == null)
        return Response.badRequest(
          body: Body.fromString('sessionId not defined'),
        );
      return await next(req);
    };
  };
}
```

I think I made some duplicated code. Anyway, not really important for the moment, it will also be another good reason to test the Dart analyzer tool, and delete dead code.

```dart
/// check if the session id exists in the sessions
/// store.
Middleware checkSessionExists() {
  return (final Handler next) {
    return (final Request req) async {
      final String sessionId = req.rawPathParameters[#session]!;
      if (!CacheSession.exists(sessionId))
        return Response.badRequest(
           body: Body.fromString('sessionId "${sessionId}" does not exist'),
        );
      return await next(req);
    };
  };
}
```

Another middleware can be used to check if a key is present in the cache. Like the previous definition, it will return a not found if it's not the case.

```dart
/// check if the key has been defined in the URL path
Middleware checkKeyExists() {
  return (final Handler next) {
    return (final Request req) async {
      final key = req.rawPathParameters[#key];
      if (key == null)
        return Response.badRequest(
          body: Body.fromString('key not defined'),
        );
      return await next(req);
    };
  };
}
```

3 middlewares have been created, more of them can be added, but let stay with that for now, if you want to have some ideas for the next ones to implement:

- a middleware to check the `:session` id, it must be a valid base64url;

- a middleware to check the `:key`, it must be a valid base64url String and limited to 64 characters;

- a middleware to check the size of the data sent by the client, it should be limited (like 65KB).

# Relic Routing

Great, we know how to create [Handlers](https://pub.dev/documentation/relic/latest/relic/Handler.html) and [Middlewares](https://pub.dev/documentation/relic/latest/relic/Middleware.html), the last step is to assemble them with the help of a routers inside a [RelicApp()](https://pub.dev/documentation/relic/latest/relic/RelicApp-class.html) object. This time, the code is stored in `lib/app.dart`.

```dart
import 'package:relic/relic.dart';
import 'handlers.dart';
import 'middlewares.dart';
```

For this application, a function called `app()` has been created. This one is returned a [`RelicApp()`](https://pub.dev/documentation/relic/latest/relic/RelicApp-class.html) object, but before returning it, the routes can be configured with the help of the followings methods:

- [`use()`](https://pub.dev/documentation/relic/latest/relic/Router/use.html) method adds a new middleware based on path pattern;

- [`get()`](https://pub.dev/documentation/relic/latest/relic/RouteEx/get.html) method is used to deal with GET HTTP method;

- [`post()`](https://pub.dev/documentation/relic/latest/relic/RouteEx/post.html) method is used to route the POST HTTP method;

- [`delete()`](https://pub.dev/documentation/relic/latest/relic/RouteEx/delete.html) method is used to deal with the DELETE HTTP method;

- [`fallback()`](https://pub.dev/documentation/relic/latest/relic/Router/fallback.html) method is the last route called if no others matched a pattern.

As you can see, all those methods are following the same structure, the first argument is used to create a path pattern and the second argument is there to add an handler.


```dart
RelicApp app() {
  return RelicApp()
    // sessions API
    ..get('/sessions', newSessionHandler)
    ..use('/sessions/:session', checkSessionId())
    ..use('/sessions/:session', checkSessionExists())
    ..delete('/sessions/:session', deleteSessionHandler)
    ..get('/sessions/:session', getSessionHandler)

    // cache API
    ..use('/cache/:session/:key', checkSessionId())
    ..use('/cache/:session/:key', checkSessionExists())
    ..use('/cache/:session/:key', checkKeyExists())
    ..get('/cache/:session', getCacheLengthHandler)
    ..get('/cache/:session/:key', getCacheHandler)
    ..post('/cache/:session/:key', postCacheHandler)
    ..delete('/cache/:session/:key', deleteCacheHandler)

    // wildcard
    ..fallback = respondWith(
      (_) => Response.notFound(
        body: Body.fromString("not found"),
      ),
    );
}
```

In the code above, all the routes and their handlers have been defined. The application is practically ready to be started.

# Application Entry Point

The last brick to this application is the entry-point. This module is stored in `bin/cache_relic.dart`. The code is straightforward: start the [`RelicApp`](https://pub.dev/documentation/relic/latest/relic/RelicApp-class.html) listener by executing the [`serve()`](https://pub.dev/documentation/relic/latest/relic/RelicAppIOServeEx/serve.html) method.

```dart
import 'package:relic/relic.dart';
import 'package:cache_relic/app.dart';

Future<void> main() async {
  await app().serve();
}
```

Voilà! It's done! The application should work now.

# Testing

All bricks are ready, the logic has been created, the middlewares and the handlers have been added in the router and the main entry-point can be executed. Let start the application.

```console
$ dart run
Building package executable... 
Built cache_relic:cache_relic.
```

We can verify if the application is listening correctly on the port TCP/8080 with the help of [`ss`]()https://manpages.debian.org/trixie/iproute2/ss.8.en.html.

```console
$ ss -nlpt sport = 8080
State               Recv-Q              Send-Q                            Local Address:Port                             Peer Address:Port              Process                                                    
LISTEN              0                   128                                   127.0.0.1:8080                                  0.0.0.0:*                  users:(("dart:cache_reli",pid=4137059,fd=9))
```

The service is listening. First step to use it, generate a new session from `/sessions` end-point.

```console
$ curl localhost:8080/sessions
xYgo--V1c8Bmu8Gp-y1WeQ==
```

The session id is `xYgo--V1c8Bmu8Gp-y1WeQ==`, let use it to store our first data into the cache with the help of `/cache/xYgo--V1c8Bmu8Gp-y1WeQ==/${key}` end-point.

```console
$ curl -XPOST -dtest localhost:8080/cache/xYgo--V1c8Bmu8Gp-y1WeQ==/test
ok
```

It looks good, but can we be sure it has been correctly stored? We can check that with the `/cache/xYgo--V1c8Bmu8Gp-y1WeQ==/${key}` end-point.

```console
$ curl -XGET localhost:8080/cache/xYgo--V1c8Bmu8Gp-y1WeQ==/test
test
```

Nice! It seems our data has been correctly stored! Let delete it now, still with the `/cache/xYgo--V1c8Bmu8Gp-y1WeQ==/${key}` end-point.

```console
$ curl -XDELETE localhost:8080/cache/xYgo--V1c8Bmu8Gp-y1WeQ==/test
ok
```

The end-point returns `ok`, but let check if it's really the case.

```console
$ curl -XGET localhost:8080/cache/xYgo--V1c8Bmu8Gp-y1WeQ==/test
not found
```

That's good, the data has been correctly removed from the cache store. Let check now the other features we added, especially on the session side. One feature is to check if a session exists, it has been added on the `/sessions/xYgo--V1c8Bmu8Gp-y1WeQ==` end-point.

```console
$ curl -v -XGET localhost:8080/sessions/xYgo--V1c8Bmu8Gp-y1WeQ==
Note: Unnecessary use of -X or --request, GET is already inferred.
* Host localhost:8080 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
* HTTPS-RR: -
*   Trying [::1]:8080...
* connect to ::1 port 8080 from ::1 port 57168 failed: Connection refused
*   Trying 127.0.0.1:8080...
* Established connection to localhost (127.0.0.1 port 8080) from 127.0.0.1 port 49010 
* using HTTP/1.x
> GET /sessions/xYgo--V1c8Bmu8Gp-y1WeQ== HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/8.20.0
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 200 OK
< content-type: text/plain; charset=utf-8
< date: Sun, 07 Jun 2026 16:20:40 GMT
< content-length: 0
< 
* Connection #0 to host localhost:8080 left intact
```

It returns a 200 HTTP Code, it means it exists. Let delete the session now.

```console
$ curl -v -XDELETE localhost:8080/sessions/xYgo--V1c8Bmu8Gp-y1WeQ==
xYgo--V1c8Bmu8Gp-y1WeQ==
```

The session id is returned to the client, and the server looks happy. Let check if the session has been correctly removed.

```console
$ curl -XGET localhost:8080/sessions/xYgo--V1c8Bmu8Gp-y1WeQ==
sessionId "xYgo--V1c8Bmu8Gp-y1WeQ==" does not exist
```

The `xYgo--V1c8Bmu8Gp-y1WeQ==` session does not exist anymore. I think the application is working has expected.

# Conclusion

The implementation is working correctly, but the code looks dirty, using for example something like a factory to deal with the instantiated objects does not seem to be the right way. In fact, using a factory like that can probably lead to race conditions and other issues. In fact, the factories in Dart are more black magic stuff, even in the language specifications, it's kinda hard to understand how they are working or how they have been implemented.

Furthermore, because this "project" was a draft to test factories in Dart, no tests have been created (really bad practices), but it was also not designed to be used in production! So, be careful if you want to use it for one of your project, and please review it.

Anyway, here a list of cool features to add:

- Test:
  - Add tests for middlewares
  - Add tests for handlers
  - Add integration tests

- Global:
  - the session ttl can be set from the CLI (e.g. `--session.ttl=60`);
  - the session limit size can be set from the CLI (e.g. `--session.size.max=123`);
  - the default key size can be changed from the CLI (e.g. `--cache.key.size.max=123`);
  - the default value size can be changed from the CLI (e.g. `--cache.value.size.max=123`);
  - those parameters could be stored in another immutable factory.

- Session:
  - Only a limited amount of session can be created, if full, the API returns not more sessions can't be created (session cache full);
  - A session has a limited period of validity (60s), after this period, it is automatically removed, except if the client ask for more time;
  - A session is limited in size (bytes);
  - A session can be exported as JSON.

- Cache:
  - A store key can be copied to another existing session;
  - The `x-cache-session-ttl` can be added on all request, it will contain the remaining times before the session will be removed.

As usual, if you want to know a bit more, dig a bit deeper into this topic, here few resources that could probably help you:

- [Relic package](https://pub.dev/packages/relic) on pub.dev;

- [Relic API Documentation](https://pub.dev/documentation/relic/latest/), where you will find the full documentation of the API;

- [Official Relic Website](https://docs.dartrelic.dev/), where you will find the official documentation and lot of examples;

- [Relic Repository](https://github.com/serverpod/relic) at Github, where you will find the full relic implementation source code, you should check the examples and the test suite;

- [`in_memory_store` package](https://pub.dev/packages/in_memory_store), this package would have been a great alternative to store data in memory, adding and testing it in the future could be great.

The repository containing the source code can be found in [`niamtokik/cache_relic`](https://github.com/niamtokik/cache_relic) repository on Github.

----

Cover Image by <a href="https://unsplash.com/@daneelzam?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Daniil Zameshaev</a> on <a href="https://unsplash.com/photos/a-table-topped-with-lots-of-brown-vases-pTxV4nn6S6A?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>