---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/tests-and-coverage-in-dart-5ahm"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fo5iewiqbz47srwt4xk6z.jpg"
created_at: "None"
crossposted_at: "None"
description: "Writing tests is one of the most important and tedious task a developer has to do. A test is more..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/tests-and-coverage-in-dart-5ahm"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "tests-and-coverage-in-dart-5ahm"
social_image: "None"
title: "Tests and Coverage in Dart"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Tests and Coverage in Dart

Writing tests is one of the most important and tedious task a developer has to do. A test is more than proving something is working in a project - even if it's main goal, it's also a way to see how an API is working, by offering implicit use cases and representing data using different format (mocking).

It's usually a good practice to create the test first and then implement the solution. This is the foundation of both [Test-driven Development](https://en.wikipedia.org/wiki/Test-driven_development) (TDD) and [Extreme Programming](https://en.wikipedia.org/wiki/Extreme_programming) (XP) methodologies.

In TDD, the test must be written first, and must fail. During the next iteration, the developer will invest time and effort to ensure the test is passing. In XP, this is practically the same, except this methodology has been created for high speed development (game production), and the tests are also used as source of trust and documentation.

This post is not really about those methodologies, even if we can talk a bit about them, one will find more accurate resources on Wikipedia or elsewhere than reading this publication. The goal of this article is to summarize the different ways available to test an application in Dart. Dart only, not Flutter, this is a different beast, and a dedicated article will be created only for it.

# Bootstrapping

As usual, a new dedicated project will be created, let call it... `rps` for rock-paper-scissors. Let say it will be a library containing the rules for the [Jan-ken-pon](https://en.wikipedia.org/wiki/Rock_paper_scissors).

```console
$ dart create rps
Creating rps using template console...

  .gitignore
  analysis_options.yaml
  CHANGELOG.md
  pubspec.yaml
  README.md
  bin/rps.dart
  lib/rps.dart
  test/rps_test.dart

Running pub get...                     0.3s
  Resolving dependencies...
  Downloading packages...
  Changed 48 dependencies!

Created project rps in rps! In order to get started, run the following commands:

  cd rps
  dart run
```

If no template is being used to create this application, one will need to add the `test` package as dependencies in `pubspec.yaml` file, inside the `dev_dependencies` section. See below for an example.

```yaml
dev_dependencies:
  lints: ^6.0.0
  test: ^1.25.6
```

The [`test` package](https://pub.dev/packages/test) is the main one used to create test suites in Dart. It is maintained by the Dart team and available by default in the SDK.

# Rock-Paper-Scissors Rules

The Jan-ken-pon is a simple - and addictive - game. The goal is to win a duel with someone else using one of the 3 movements also called Shapes: Rock (the hand is fully closed), Paper (the hand is fully opened), and Scissors (the hand is half closed and the fingers are doing a scissors).

- The `Rock` wins over `Scissors` (then the Scissors is losing against `Rock`);

- The `Scissors` wins over `Paper` (then the Paper is losing against `Scissors`);

- The `Paper` wins over `Rock` (then the `Rock` is losing against `Paper`);

- If both players are using the same movement, it's a draw and they must start over until one win.

A quick table to summarize the final results:

| a vs b   | rock | paper | scissors |
|----------|------|-------|----------|
| rock     | draw | loss  | **win**      |
| paper    | **win**  | draw  | loss     |
| scissors | loss | **win**   | draw     |

Usually, this game is played anywhere and for any reasons (for example for the one who will eat the last chocolate desert in the restaurant). Let call the act to play with someone else a `Party`. This post will also give me the opportunity to talk about design programming and OOP. Yeah. Marvelous. Finally.

# Rock-Paper-Scissors Shapes

To me, a good programming language should give you an idea of an implementation without a lot of effort. When using Object Oriented Programming paradigm, this is never the case. You don't have one or two obvious solutions, but a bunch of potentials valid solutions. Let try to implement our shapes here (rock, paper and scissors).

Here 3 of the implementations I can think of when dealing with this project:

1. (medium complexity) Like any other OOP language, one will create a first abstract class called `Shape`, and then will create 3 classes called `Rock`, `Paper` and `Scissors` inheriting from the `Shape` class;

2. (low complexity) Because Dart is being used here, one can do something a bit different, using an enumerator as class, and extends it with few methods to compare the defined value between them;

3. (high complexity) Create a more complex data-structure, based on a ring (linked list) where the first element is linked to the last one, or a directed graph, where the different path can define which shape greater than another one. Those solutions are way more complex, but can give more flexibility and extends the game in the future with new shapes (e.g. `Spoke` and `Snake`).

The second option seems to be the easiest one for this kind of publication, so, let implement it. Let begin with something simple, the representation of the shapes using an emoji (utf8/unicode). A `test/` directory should already be present in the project, we can add a new test file called `shapes_test.dart` there.

```dart
// file test/shapes_test.dart

import 'dart:convert';
import 'package:test/test.dart';
import 'package:rps/shapes.dart' as shapes show versus;
import 'package:rps/shapes.dart' show Shape;

final utf8Encoder = utf8.encoder;

void shapeRepresentation() {
  group('Shapes Representation', () {
    // see https://unicodeplus.com/U+270A
    test('rock as raised fist unicode', () {
      expect(
        utf8Encoder.convert(Shape.rock.toString()),
        [226, 156, 138]
      );
    });

    // see https://unicodeplus.com/U+1FAF3
    test('paper as palm down hand unicode', () {
      expect(
        utf8Encoder.convert(Shape.paper.toString()),
        [240, 159, 171, 179]
      );
    });

    // see https://unicodeplus.com/U+270C
    test('scissors as victory hand unicode', () {
      expect(
        utf8Encoder.convert(Shape.scissors.toString()),
        [226, 156, 140]
      );
    });
  });
}

void main() {
  shapeRepresentation();
}
```

Here's an explanation of this code, a new test case is created with the help of the [`test()` function](https://pub.dev/documentation/test/latest/test/test.html). The first argument is the description of the test as `String`, and the next argument is an anonymous function containing the code to be executed.

A test case can be added in a test group, in this situation, the [`group()` function](https://pub.dev/documentation/test/latest/test/group.html) can be used. It follows the same principle than the `test()` function, the first argument is the description of the group as `String` and the second argument will contain the test cases to be executed.

Then, each test cases is made of functions exposed by the `test` module, in our case, the [`expect()`](https://pub.dev/documentation/test/latest/test/expect.html) function is used to assert a certain value.

```console
$ dart test
00:00 +0 -1: loading test/shapes_test.dart [E]                                                          
  Failed to load "test/shapes_test.dart":
  test/shapes_test.dart:13:29: Error: Undefined name 'Shape'.
          utf8Encoder.convert(Shape.rock.toString()),
                              ^^^^^
  test/shapes_test.dart:21:29: Error: Undefined name 'Shape'.
          utf8Encoder.convert(Shape.paper.toString()),
                              ^^^^^
  test/shapes_test.dart:29:29: Error: Undefined name 'Shape'.
          utf8Encoder.convert(Shape.scissors.toString()),
                              ^^^^^
  test/shapes_test.dart:39:14: Error: Undefined name 'Shape'.
        expect(Shape.rock > Shape.scissors, equals(true));
               ^^^^^
  test/shapes_test.dart:39:27: Error: Undefined name 'Shape'.
        expect(Shape.rock > Shape.scissors, equals(true));

00:00 +0 -1: Some tests failed.
```

The tests are failing, this is normal, nothing has been created so far. Let fix that by creating a new file called `lib/shapes.dart`, it will contain our first implementation.

```dart
// file lib/shapes.dart

enum Shape {
  rock, paper, scissors;
   
  String toString() {           
    switch (this) {
      case rock: return "✊";
      case paper: return "🫳";
      case scissors: return  "✌";
    }
  }
}
```

Let re-invoke `dart test` to see if our implementation is working correctly.

```dart
$ dart test
00:00 +3: All tests passed!
```

It works! Now we need something to compare Shapes between them; for doing that, let playing with the default operators offered by dart, mainly used to compare numbers. Why not using them to compare Shapes?

```dart
// file test/shapes_test.dart

void shapeOperators() {
  group('Shapes Operators', () {
    test('rock operators', () {
      expect(Shape.rock > Shape.scissors, equals(true));
      expect(Shape.rock < Shape.paper, equals(true));
      expect(Shape.rock == Shape.rock, equals(true));
    });

    test('scissors operators', () {
      expect(Shape.scissors > Shape.paper, equals(true));
      expect(Shape.scissors < Shape.rock, equals(true));
      expect(Shape.scissors == Shape.scissors, equals(true));
    });

    test('paper operators', () {
      expect(Shape.paper > Shape.rock, equals(true));
      expect(Shape.paper < Shape.scissors, equals(true));
      expect(Shape.paper == Shape.paper, equals(true));
    });
  });
}

void main() {
  shapeRepresentation();
  shapeOperators();
}
```

As previously said, the test cases are grouped together. The code here describes how the Shapes will interact when using [`>`](https://api.dart.dev/dart-core/BigInt/operator_greater.html) (greater than) and [`<`](https://api.dart.dev/dart-core/BigInt/operator_less.html) (less than) operators. The code is straightforward and explicit, but one could have done probably more tests with the help of the huge amount of function helpers offered by the `test` package, here a short list of them:

- [`isFalse`](https://pub.dev/documentation/test/latest/test/isFalse-constant.html) constant, ensure the final result is returning `false` as boolean;

- [`isTrue`](https://pub.dev/documentation/test/latest/test/isTrue-constant.html) constant, same than `isFalse` except it ensure the returned value is `true`;

- [`isException()`](https://pub.dev/documentation/test/latest/test/isException-constant.html) contant can be used to be sure the function will throw an exception;

- [`contains()`](https://pub.dev/documentation/test/latest/test/contains.html) function checks if the returned values contain a specific objects;

- [`fail()`](https://pub.dev/documentation/test/latest/test/fail.html) function throws a failure;

- [`isA()`](https://pub.dev/documentation/test/latest/test/isA.html) function checks the type of the data returned;

- [`same()`](https://pub.dev/documentation/test/latest/test/same.html) function checks if 2 items are identical.

Anyway, let implement these new requested features to compare `Shapes` using our standard operators. To do that, we will create methods marked with the `operator` identifier. From the specification:

> Operators are instance methods with special names, except for operator `[]` which is an instance getter and operator `[]=` which is an instance setter. An operator declaration is identified using the built-in identifier `operator`.
> 
> -- [Dart Programming Language Specification](https://storage.googleapis.com/dart-specification/DartLangSpecDraft.pdf), Chapter 10, Section 2.1, page 37

In our case, the methods `<` and `>` will be created. They must return a boolean.

```dart
// file lib/shapes.dart

enum Shape {
  rock, paper, scissors;
   
  String toString() {           
    switch (this) {
      case rock: return "✊";
      case paper: return "🫳";
      case scissors: return  "✌";
    }
  }
   
  bool operator <(Shape other) {
    switch ((this, other)) {
      case (rock, paper): return true;
      case (rock, scissors): return false;
      case (paper, rock): return false;
      case (paper, scissors): return true;
      case (scissors, paper): return true;
      case (scissors, rock): return false;
      case (rock,rock): return false;
      case (paper,paper): return false;
      case (scissors,scissors): return false;
    }
  }
   
  bool operator >(Shape other) {
    switch ((this, other)) {
      case (rock, paper): return false;
      case (rock, scissors): return true;
      case (paper, rock): return true;
      case (paper, scissors): return false;
      case (scissors, paper): return true;
      case (scissors, rock): return false;
      case (rock,rock): return false;
      case (paper,paper): return false;
      case (scissors,scissors): return false;
    }
  }
}
```

Now the implementation is done, let runs the tests.

```dart
$ dart test
Building package executable... 
Built test:test.
00:00 +6: All tests passed! 
```

Great, finally, we need an easy way to know if a shape versus another can be defined as a `Win`, a `Loss` or a `Draw`. It can be implemented as an exposed function from the module `Shapes` directly, we don't need something smart, just a function doing a comparison with two `Shape`.

```dart
// file test/shapes_test.dart

import 'package:rps/results.dart';

void shapeVersus() {
  print(shapes.versus(Shape.rock, Shape.scissors));
  group('Shapes Versus', () {
    test('rock', () {
      expect(
        shapes.versus(Shape.rock, Shape.scissors).toString(),
        equals("Win")
      );
      expect(
        shapes.versus(Shape.rock, Shape.rock).toString(),
        equals("Draw")
      );
      expect(
        shapes.versus(Shape.rock, Shape.paper).toString(),
        equals("Loss")
      );
    });
  });
}
```

New problem. How to represent a `Draw`, a `Win` and a `Loss`? Well, all can be seen as `Result`, so, let create at first an abstract class called `Result` first. Then, we can create the needed classes. This code will be stored in `lib/results.dart`.

```dart
// file lib/results.dart

abstract class Result {}

class Draw extends Result {
  toString() => "Draw";
}

class Win extends Result {
  toString() => "Win";
}

class Loss extends Result {
  toString() => "Loss";
}
```

Great, let work on the `versus()` function, we can implement it in many ways, let implement the easiest one, using the operators previously created.

```dart
// file lib/shapes.dart

Result versus(Shape left, Shape right) {
  if (left == right) return Draw();
  if (left > right) return Win();
  if (left < right) return Loss();
  throw("error");
}
```

Now our implementation is done, let check the tests.

```console
$ dart test
00:00 +7: All tests passed!
```

Now we have a quick and dirty implementation of the different available Shapes in Jan Ken Pon, let have a look on the `test` package and all the features it offers us.

# Test Reports

The `test` package offers a way to create test reports using [reporters](https://pub.dev/packages/test#selecting-a-test-reporter). The default reporter used is the `compact` one, only printing the sum of successful test or printing the errors. Another simple reporter is the `expanded` one, it will display more information about the test suite.

```console
$ dart test --reporter=expanded
00:00 +0: loading test/rps_test.dart
00:00 +0: test/shapes_test.dart: Shapes Representation rock as raised fist unicode
00:00 +1: test/shapes_test.dart: Shapes Representation paper as palm down hand unicode
00:00 +2: test/shapes_test.dart: Shapes Representation scissors as victory hand unicode
00:00 +3: test/shapes_test.dart: Shapes Operators rock operators
00:00 +4: test/shapes_test.dart: Shapes Operators scissors operators
00:00 +5: test/shapes_test.dart: Shapes Operators paper operators
00:00 +6: test/shapes_test.dart: Shapes Versus rock
```

If your project is running on Github and you are using Github Actions, a specific reporter called `github` can be used and will output a Github friendly report.

```console
$ dart test --reporter=github

::group::✅ Passing tests
✅ test/shapes_test.dart: Shapes Representation rock as raised fist unicode
✅ test/shapes_test.dart: Shapes Representation paper as palm down hand unicode
✅ test/shapes_test.dart: Shapes Representation scissors as victory hand unicode
✅ test/shapes_test.dart: Shapes Operators rock operators
✅ test/shapes_test.dart: Shapes Operators scissors operators
✅ test/shapes_test.dart: Shapes Operators paper operators
✅ test/shapes_test.dart: Shapes Versus rock
::endgroup::

🎉 7 tests passed.
```

Finally, if you are using your own CI/CD pipeline with Jenkins or [Robot Framework](https://robotframework.org/), the result of the test can be returned as JSON with the `json` reporter.

```console
$ dart test --reporter=json
{"protocolVersion":"0.1.1","runnerVersion":"1.31.1","pid":3420883,"type":"start","time":0}
{"suite":{"id":0,"platform":"vm","path":"test/rps_test.dart"},"type":"suite","time":0}
{"test":{"id":1,"name":"loading test/rps_test.dart","suiteID":0,"groupIDs":[],"metadata":{"skip":false,"skipReason":null},"line":null,"column":null,"url":null},"type":"testStart","time":0}
...
{"success":true,"type":"done","time":310}
```

# Test Coverage


Generating a [coverage report](https://pub.dev/packages/test#collecting-code-coverage) via `dart test` requires [LCOV tool](https://github.com/linux-test-project/lcov) installed on your system. If you are using a Debian-like distribution, the LCOV package should be available.

```console
$ sudo apt-get install lcov
```

To generate a new coverage report, simply use `--coverage-path` arguments. It will create the directory destination if it does not exist and generate the report.

```console
$ dart run test --coverage-path=./_coverage/lcov.info
00:00 +7: All tests passed!
```

If you want to have an HTML report, the [`genhtml`](https://manpages.debian.org/trixie/lcov/genhtml.1.en.html) command usually present with the LCOV package is needed. It will generate an HTML report in the same directory the `lcov.info` file has been created.

```console
$ genhtml -o _coverage/report ./_coverage/lcov.info 
Reading tracefile ./_coverage/lcov.info.
Found 3 entries.
Found common filename prefix "/dart/rps"
Generating output.
Processing file lib/rps.dart
  lines=2 hit=0
Processing file lib/results.dart
  lines=3 hit=3
Processing file lib/shapes.dart
  lines=28 hit=18
Overall coverage rate:
  source files: 3
  lines.......: 63.6% (21 of 33 lines)
  functions...: no data found
Message summary:
  no messages were reported
```

Now, the final result. See below the 3 levels of coverage from the top layer (a global view of the application) and the 2 other layers. The third one is the coverage from the module directly, indicating the numbers of time a line is called.

![Top Level Coverage Report](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/jj85sgrqpqqi72wiow30.png)

![Lib Coverage Report](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/rnaum6dp1k5xr4h8839h.png)

![Shapes Module Coverage Report](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/gd1r8zcc4upd0dc75ji3.png)

# Conclusion

Testing an application with Dart is an easy task, the tools offered by default are doing what any developer is looking for, unit testing, test coverage and reports. It was a really quick introduction to this complex topic, we still have a lot of things to learn, like mocking techniques, test integration, testing frontend, backend or flutter and much more.

The skeleton of this project can be found in [niamtokik/rps_dart](https://github.com/niamtokik/rps_dart) repository on Github. If you are still there and want to know more, here a list of interesting resources:

- [Dart testing guide](https://dart.dev/tools/testing) where you will find a quick introduction to testing and more resources;

- [Dart testing tutorial](https://dart.dev/learn/tutorial/testing)  where you will find a complete test project example in Dart;

- [`test` package](https://pub.dev/packages/test) on pub.dev;

- [`test` package API documentation](https://pub.dev/documentation/test/latest/) where you will find the full documentation of the `test` package;

- [`test` package source code](https://github.com/dart-lang/test/tree/master/pkgs/test) on Github, where you will find the implementation of the `test` package;

- [Test-Driven Development (TDD) in Flutter: a Practical Guide with Runnable Examples](https://medium.com/@lord.oussama.2020/test-driven-development-tdd-in-flutter-a-practical-guide-with-runnable-examples-ec844761a03c) by [Oussama DX](https://medium.com/@lord.oussama.2020) on Medium, where you will learn how to test Flutter;

- [Test-Driven Development (TDD) in Dart
](https://github.com/Yczar/test-driven-dart/blob/master/6_Special_Topics/6.1_TDD_in_Dart.md) by [Ayatomide](https://github.com/Yczar/) on Github, where you will an example of TDD in Dart;

- [Unit Testing (TDD) in Dart: A Beginners Guide Part I](https://nooralibutt.com/unit-testing-tdd-in-dart-469aee03aa4b) by [Noor Ali](https://nooralibutt.com/) on Medium where you will learn how to use TDD in Dart;

- [Test-Driven Development with Dart: Ensuring Code Quality](https://clouddevs.com/dart/test-driven-development/) by [CloudDevs](https://clouddevs.com/).

Have fun!

----

Cover Image by <a href="https://unsplash.com/@tomcrewceramics?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Tom Crew</a> on <a href="https://unsplash.com/photos/white-garlic-on-gray-table-yKmBMyxndsI?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>